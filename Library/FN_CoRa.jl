# Steady state & DY calculation functions
#		Julia v.1.6

module fn
	# Required libraries
	using DelimitedFiles
	using Distributions
	using DifferentialEquations
	using ModelingToolkit

	###This function is rather simple, but it's for readability in the main code purposes, and prevention of typos
	function Restart(a, b)
		a = zeros(length(a)).+NaN;
		b = zeros(length(b)).+NaN;
		return a, b
	end;

	###Can't have a steady state & check function without the steady state and the checking, now can we?
	function SS(syst, p, x0, rtol)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		tS = 0;
		dXrm = 1;
		while(dXrm > rtol)
			ss = try
				fn.solve(fn.ODEProblem(syst,x0,1e6,pV); reltol=rtol,save_everystep = false);
			catch
				try
					fn.solve(fn.ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					x0 = zeros(length(syst.syms)).+NaN;
					break
				end
			end;
			if ss.retcode == :Unstable
				try
					ss = fn.solve(fn.ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					x0 = zeros(length(syst.syms)).+NaN;
					break
				end
			end
			dXrm = maximum(abs.(big.(ss(1e6))-big.(ss(1e6-0.01)))./big.(ss(1e6)));
			x0 = ss(1e6);
			tS += 1e6;
			if(tS>1e12)
				println("WARNING: Maximum iteration reached (simulated time 1e18). Max relative Delta: ",dXrm)
				break
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
		if(abs(mm.outFB(ssR) - mm.outNF(soR)) > 1e-4)
			rtol *= 1e-3;
			if(rtol < 1e-24)
				println("ERROR: Check NF system (reltol=",rtol,").")
				println(vcat(pp,i,[p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps],mm.outFB(ssR),mm.outNF(soR)))
				if(abs(mm.outFB(ssR) - mm.outNF(soR))/mm.outFB(ssR) > 0.01)
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
	function SSandCheck(p, x0, rtol, mm, pp)
		###The rtol value basically states that this will be attempted 5 times: This is because of the comparison made in "if(abs(mm.outFB(ssR) - mm.outNF(soR)) > 1e-4)". If that is successful
		###Then the value of rtol is multiplied by 1e-3, until it is no longer greater or equal than 1e-24, as stated in our while() condition
		flag = "Insufficient"
		ssR, soR = fn.Restart(x0, x0)
		while(rtol >= 1e-24 && flag == "Insufficient")
			# Reference steady state:
			ssR = fn.SS(mm.odeFB, p, x0, rtol);
			if(fn.NaNCheck(ssR, soR) != "Valid")
				println("Condition excluded! ssR --> NaN");
				break;
			end
			# Locally analogous system reference steady state:
			mm.localNF(p,ssR);
			###Of note here, instead of using the initial condition x0, we use ssR.
			soR = fn.SS(mm.odeNF, p, ssR, rtol);
			if(fn.NaNCheck(soR, ssR) != "Valid")
				println("Condition excluded! soR --> NaN");
				break;
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
		return log10.(ssD/ssR) ./ log10.(soD/soR);
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
		# Check if the difference reaches negative values
		if	all(logYFB .>= 0)
			# If it does not, calculate CoRaDyn
			print("Trap", "\n")
			print(yNF.t[j] * sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1])), " ",(yFB.t[i] * sum(abs.(log10.(mm.solNF(yNF)[1:j-1] .* mm.solNF(yNF)[2:j] ./ mm.outNF(soR)^2)) .* (yNF.t[2:j] .- yNF.t[1:j-1]))), "\n")
			return (yNF.t[j] * sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1]))) / (yFB.t[i] * sum(abs.(log10.(mm.solNF(yNF)[1:j-1] .* mm.solNF(yNF)[2:j] ./ mm.outNF(soR)^2)) .* (yNF.t[2:j] .- yNF.t[1:j-1])))
		else
			# If it does, calculate CoRaDyn in such a way that it removes part of the error
			# But first, get the indexes where the error occurs
			k = findfirst((logYFB[1:i-1] .* logYFB[2:i]) .< 0)
			# Take the absolute value of all the differences
			logYFB = abs.(logYFB)
			print("Correction", "\n")
			print(yNF.t[j] * (sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1])) - (2 * sum((logYFB[k] .* logYFB[k .+ 1] .* (yFB.t[k .+ 1] .- yFB.t[k])) ./ (logYFB[k] .+ logYFB[k .+ 1])))), " ",(yFB.t[i] * sum(abs.(log10.(mm.solNF(yNF)[1:j-1] .* mm.solNF(yNF)[2:j] ./ mm.outNF(soR)^2)) .* (yNF.t[2:j] .- yNF.t[1:j-1]))), "\n")
			return (yNF.t[j] * (sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1])) - (2 * sum((logYFB[k] .* logYFB[k .+ 1] .* (yFB.t[k .+ 1] .- yFB.t[k])) ./ (logYFB[k] .+ logYFB[k .+ 1]))))) / (yFB.t[i] * sum(abs.(log10.(mm.solNF(yNF)[1:j-1] .* mm.solNF(yNF)[2:j] ./ mm.outNF(soR)^2)) .* (yNF.t[2:j] .- yNF.t[1:j-1])))
		end 
	end;

	function Dyn(syst, p, x0, tspan, rtol, saveat, tstops)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		xD = try
			fn.solve(fn.ODEProblem(syst,x0,tspan,pV); saveat = saveat, tstops = tstops, reltol=rtol);
		catch
			try
				fn.solve(fn.ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; saveat = saveat, tstops = tstops, reltol=rtol);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end;
		if xD.retcode == :Unstable
			try
				xD = fn.solve(fn.ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; saveat = saveat, tstops = tstops, reltol=rtol);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end
		return(xD)
	end
end
