# Steady state & DY calculation functions
#		Julia v.1.6

module fn
	# Required libraries
	using DelimitedFiles
	using Distributions
	using DifferentialEquations
	using ModelingToolkit
	using LinearAlgebra

	###This function is rather simple, but it's for readability in the main code purposes, and prevention of typos
	function Restart(a, b)
		a = fill(NaN, length(a)); 
		b = fill(NaN, length(b));
		return a, b
	end;

	###Can't have a steady state & check function without the steady state and the checking, now can we?
	function SS(syst, p, x0, rtol)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		tS = 0;
		dXrm = 1;
		prev_states = []

		while(dXrm > rtol)
			ss = try
				fn.solve(fn.ODEProblem(syst,x0,1e6,pV); reltol=rtol,save_everystep = false);
			catch
				try
					fn.solve(fn.ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					# x0 = zeros(length(syst.syms)).+NaN;
					# break
					return fill(NaN, length(x0))
				end
			end;
			if SciMLBase.successful_retcode(ss) == false
				try
					ss = fn.solve(fn.ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					# x0 = zeros(length(syst.syms)).+NaN;
					# break
					return fill(NaN, length(x0))
				end
			end

			dXrm = maximum(abs.(big.(ss(1e6))-big.(ss(1e6-0.01)))./big.(ss(1e6)));

			# Store states and check for oscillations
			push!(prev_states, ss(1e6))
			if length(prev_states) > 5  # Keep last 5 states
				prev_states = prev_states[2:end]
			end

			# Oscillation Detection (Separate from dXrm)
			if length(prev_states) >= 3
				diffs = [norm(prev_states[i] - prev_states[i - 1]) for i in 2:length(prev_states)]
				if std(diffs) > 1e-3  # High standard deviation → likely oscillatory
					println("WARNING: Oscillatory behavior detected! Skipping condition.")
					return fill(NaN, length(x0))
				end
			end

			x0 = ss(1e6);
			tS += 1e6;

			if(tS>1e12)
				println("WARNING: Maximum iteration reached (simulated time 1e18). Max relative Delta: ",dXrm)
				# break
				return fill(NaN, length(x0))
			end
		end
		return x0
	end;

	###A small function to check for NaNs, again made for the purposes of readability within the code
	function NaNCheck(a, b) 
		if(any(isnan.(a)))
			a, b = fn.Restart(a, b)
			return a, b
		else
			return "Valid"
		end
	end;

	###Now we create the Check function!
	function Check(ssR, soR, rtol, mm, pp)
		if (abs(mm.outFB(ssR) - mm.outNF(soR)) > 1e-4)
			rtol *= 1e-3;
			if (rtol < 1e-24)
				println("ERROR: Check NF system (reltol=",rtol,").")
				println(vcat(pp,i,[p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps],mm.outFB(ssR),mm.outNF(soR)))
				if (abs(mm.outFB(ssR) - mm.outNF(soR))/mm.outFB(ssR) > 0.01)
					ssR, soR = Restart(ssR, soR);
					println("Error too large. SS results excluded!")
				end
			end
			return ssR, soR, rtol, "Insufficient"
		else
			return ssR, soR, rtol, "Sufficient"
		end
	end;

	###Here it is, the SS&Check function. It will, of course, be built upon an SS() and a Check() funciton previously defined within this document
	### Estimates SS of both the FB and NF systems and checks that they are equal
	function SSandCheck(p, x0, rtol, mm, pp)
		###The rtol value basically states that this will be attempted 5 times: This is because of the comparison made in "if(abs(mm.outFB(ssR) - mm.outNF(soR)) > 1e-4)". If that is successful
		###Then the value of rtol is multiplied by 1e-3, until it is no longer greater or equal than 1e-24, as stated in our while() condition
		flag = "Insufficient"
		ssR, soR = fn.Restart(x0, x0)

		while(rtol >= 1e-24 && flag == "Insufficient")
			# Reference steady state:
			ssR = fn.SS(mm.odeFB, p, x0, rtol)
			if (fn.NaNCheck(ssR, soR) != "Valid")
				println("Condition excluded! ssR --> NaN");
				# break;
				return ssR, soR, rtol
			end
			# Locally analogous system reference steady state:
			mm.localNF(p,ssR);
			###Of note here, instead of using the initial condition x0, we use ssR.
			soR = fn.SS(mm.odeNF, p, ssR, rtol);
			if (fn.NaNCheck(soR, ssR) != "Valid")
				println("Condition excluded! soR --> NaN");
				# break;
				return ssR, soR, rtol
			end
			if any((ssR .< 0)) || any((soR .< 0))
				ssR, soR = Restart(ssR, soR);
				println("The solutions reach negative numbers. SS results excluded!")
				return ssR, soR, rtol
			end
			ssR, soR, rtol, flag = Check(ssR, soR, rtol, mm, pp)
		end
		return ssR, soR, rtol
	end;

	function Perturbation(ssR, soR, p, rtol, mm, pp, d)
		p[pp] *= d;
		ssD = fn.SS(mm.odeFB, p, ssR, rtol);
		soD = fn.SS(mm.odeNF, p, soR, rtol);
		p[pp] /= d;
		return ssD, soD
	end;

	function CoRa(ssR, ssD, soR, soD)
		if abs(log10(last(soD)/soR)) < 1e-4
			return NaN
		end
		return abs.(log10.(ssD/ssR)) ./ abs.(log10.(soD/soR));
	end;

	function CoRaDyn(t, yFB, ssR, yNF, soR, mm)
		# Save the index where the simulation has reached the maximum time given by the user
		i = findfirst(yFB.t .== t)
		j = findfirst(yNF.t .== t)
		# Display a warning if one of the simulations did not reach the said maximum time
		if yFB.t[i] != yNF.t[j]
			println("WARNING: Error in ODE simulation: FB tspan different from NF tspan. FB tspan = ",yFB.t[i]," NF tspan = ",yNF.t[j])
		end
		# Calculate the logarithmic difference between the post and pre perturbation states of the system with feedback
		logYFB = log10.(mm.solFB(yFB)[1:i] ./ mm.outFB(ssR)) 
		logYNF = abs.(log10.(mm.solNF(yNF)[1:j] ./ mm.outFB(soR))) # Absolute value is needed for negative perturbations 
		# Check if the difference reaches negative values
		if	((findfirst(logYFB .< 0) != nothing) * (findfirst(logYFB .> 0) != nothing)) == false
			# If it does not, calculate CoRaDyn
			logYFB = abs.(logYFB) # Absolute value is needed for negative perturbations
			return (yNF.t[j] * sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1]))) / (yFB.t[i] * sum((logYNF[1:j-1] .+ logYNF[2:j]) .* (yNF.t[2:j] .- yNF.t[1:j-1])))
		else
			# If it does, calculate CoRaDyn in such a way that it removes part of the error
			# But first, get the indexes where the error occurs
			k = findfirst((logYFB[1:i-1] .* logYFB[2:i]) .< 0)
			# Take the absolute value of all the differences
			logYFB = abs.(logYFB)
			return (yNF.t[j] * (sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1])) - (2 * sum((logYFB[k] .* logYFB[k .+ 1] .* (yFB.t[k .+ 1] .- yFB.t[k])) ./ (logYFB[k] .+ logYFB[k .+ 1]))))) / (yFB.t[i] * sum((logYNF[1:j-1] .+ logYNF[2:j]) .* (yNF.t[2:j] .- yNF.t[1:j-1])))
		end
	end;

	function CoRaDynRect(t, yFB, ssR, yNF, soR, mm)
		# Save the index where the simulation has reached the maximum time given by the user
		i = findfirst(yFB.t .== t)
		j = findfirst(yNF.t .== t)
		# Display a warning if one of the simulations did not reach the said maximum time
		if yFB.t[i] != yNF.t[j]
			println("WARNING: Error in ODE simulation: FB tspan different from NF tspan. FB tspan = ",yFB.t[i]," NF tspan = ",yNF.t[j])
		end
		# Calculate the logarithmic difference between the post and pre perturbation states of the system with feedback
		logYFB = abs.(log10.(mm.solFB(yFB)[1:i-1] ./ mm.outFB(ssR)))
		logYNF = abs.(log10.(mm.solNF(yNF)[1:j-1] ./ mm.outNF(soR)))
		# Check if the difference reaches negative values
		return (yNF.t[j] * sum(logYFB .* (yFB.t[2:i] .- yFB.t[1:i-1]))) / (yFB.t[i] * sum(logYNF .* (yNF.t[2:j] .- yNF.t[1:j-1])))
	end;

	function Dyn(syst, p, x0, tspan, rtol, saveat, tstops)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		xD = try
			fn.solve(fn.ODEProblem(syst,x0,tspan,pV); saveat = saveat, tstops = tstops, reltol=rtol);
			print(xD)
		catch
			try
				fn.solve(fn.ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; saveat = saveat, tstops = tstops, reltol=rtol);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end;
		if SciMLBase.successful_retcode(xD) == false
			try
				xD = fn.solve(fn.ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; saveat = saveat, tstops = tstops, reltol=rtol);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end
		return(xD)
	end

	function FindAdapTime(ssR, mm, p, tspan, rtol, saveat, tstops, values)
		yFB = fn.Dyn(mm.odeFB, p, ssR, tspan + 1e4, rtol, saveat, tstops);
		epsilon = maximum(abs.(mm.solFB(yFB) .- mm.outFB(ssR))) * 0.05
		i = findlast(((mm.outFB(ssR) + epsilon) .>= mm.solFB(yFB) .>= (mm.outFB(ssR) - epsilon)) .== 0)
		if i == length(yFB)
			Adapted = 0
			print("The system lost adaptation capacity:", values)
			AdapTime = NaN
			return Adapted, AdapTime
		end 
		Adapted = 1
		AdapTime = yFB.t[i + 1] # We may not obtain the exact time when XC = XCss ± ε, but it is good enough for now
		return Adapted, AdapTime 
	end 
end
