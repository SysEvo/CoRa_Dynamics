### Functions to compute steady states, simulate dynamics, and evaluate CoRa and CoRaDyn
## Julia v.1.6

module fn
	## Required libraries
	using DelimitedFiles
	using Distributions
	using DifferentialEquations
	using ModelingToolkit
	using LinearAlgebra


	## Reset the input vectors `a` and `b` to `NaN` values if computations are unsuccessful.
	function Restart(a, b)
		a = fill(NaN, length(a)); 
		b = fill(NaN, length(b));
		return a, b
	end;

	## Function to find steady states
	# This function simulates the system dynamics until a steady state is reached,
	# defined as a relative change below the given rtol threshold.
	function SS(syst, p, x0, rtol)
		# Extract parameter values
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		tS = 0;				# Total simulated time
		dXrm = 1;			# Initial relative change
		prev_states = [] 	# Buffer to store recent states for oscillation detection

		while(dXrm > rtol)
			# Attempt to solve the ODE system normally
			ss = try
				fn.solve(fn.ODEProblem(syst,x0,1e6,pV); reltol=rtol,save_everystep = false);
			catch
				# Retry using stiffness hints if the first solver fails
				try
					fn.solve(fn.ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				# If still fails, return NaNs
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					return fill(NaN, length(x0))
				end
			end;
			# Check if solution is marked as unsuccessful
			if SciMLBase.successful_retcode(ss) == false
				# Retry with stiffness hint if needed
				try
					ss = fn.solve(fn.ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					return fill(NaN, length(x0))
				end
			end

			# Compute max relative change between final two nearby time points
			dXrm = maximum(abs.(big.(ss(1e6))-big.(ss(1e6-0.01)))./big.(ss(1e6)));

			# Save final state to history for oscillation detection
			push!(prev_states, ss(1e6))
			if length(prev_states) > 5  # Keep last 5 states
				prev_states = prev_states[2:end]
			end

			# Oscillation detection: check standard deviation of recent state differences
			if length(prev_states) >= 3
				diffs = [norm(prev_states[i] - prev_states[i - 1]) for i in 2:length(prev_states)]
				if std(diffs) > 1e-3  # High standard deviation → likely oscillatory
					println("WARNING: Oscillatory behavior detected! Skipping condition.")
					return fill(NaN, length(x0))
				end
			end

			# Update initial condition for next integration round
			x0 = ss(1e6);
			tS += 1e6;

			# Stop if simulated time exceeds threshold
			if(tS>1e12)
				println("WARNING: Maximum iteration reached (simulated time 1e18). Max relative Delta: ",dXrm)
				return fill(NaN, length(x0))
			end
		end
		# Return steady state
		return x0
	end;

	## Check if the vector `a` contains any `NaN` values. If so, reset both `a` and `b` to `NaN` using `Restart`.
	function NaNCheck(a, b) 
		if(any(isnan.(a)))
			a, b = fn.Restart(a, b)
			return a, b
		else
			return "Valid"
		end
	end;

	## Compare the steady states of the feedback (`ssR`) and no-feedback (`soR`) systems.
	function Check(ssR, soR, rtol, mm, pp)
		if (abs(mm.outFB(ssR) - mm.outNF(soR)) > 1e-4)
			rtol *= 1e-3; # Tighten the relative tolerance to attempt a more accurate ODE solution
			if (rtol < 1e-24)
				println("ERROR: Check NF system (reltol=",rtol,").")
				# Print full parameters and outputs to diagnose issue
				println(vcat(pp,i,[p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps],mm.outFB(ssR),mm.outNF(soR)))
				# If relative error still > 1%, discard steady states
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

	## Compute and verify steady states for feedback and no-feedback systems
	# This function estimates the steady states (SS) of two related systems: the feedback (FB) system and the 
	# locally analogous no-feedback (NF) system. It iteratively refines the numerical tolerance (rtol) used in 
	# ODE solving to ensure the two steady states produce sufficiently similar outputs. If the outputs differ 
	# beyond a set threshold, the tolerance is tightened and the computation retried until success or a minimum 
	# tolerance is reached.
	function SSandCheck(p, x0, rtol, mm, pp)
		# Initialize flag to track whether the comparison is successful
		flag = "Insufficient"
		# Initialize steady state vectors as NaNs
		ssR, soR = fn.Restart(x0, x0)
		# Attempt to compute and verify steady states until tolerance becomes too small
		while(rtol >= 1e-24 && flag == "Insufficient")
			# Compute steady state of the feedback (FB) system
			ssR = fn.SS(mm.odeFB, p, x0, rtol)
			if (fn.NaNCheck(ssR, soR) != "Valid")
				println("Condition excluded! ssR --> NaN");
				return ssR, soR, rtol
			end
			# Compute locally analogous no-feedback (NF) system steady state using ssR as initial condition
			mm.localNF(p,ssR);
			soR = fn.SS(mm.odeNF, p, ssR, rtol);
			if (fn.NaNCheck(soR, ssR) != "Valid")
				println("Condition excluded! soR --> NaN");
				return ssR, soR, rtol
			end
			# Exclude solutions that produce any negative steady state values
			if any((ssR .< 0)) || any((soR .< 0))
				ssR, soR = Restart(ssR, soR);
				println("The solutions reach negative numbers. SS results excluded!")
				return ssR, soR, rtol
			end
			# Check if outputs of FB and NF systems are sufficiently close
			ssR, soR, rtol, flag = Check(ssR, soR, rtol, mm, pp)
		end
		# Return steady states and the final tolerance value
		return ssR, soR, rtol
	end;

	## Apply perturbation and obtain post-perturbation steady states
	function Perturbation(ssR, soR, p, rtol, mm, pp, d)
		# Apply perturbation
		p[pp] *= d;
		# Computes steady states
		ssD = fn.SS(mm.odeFB, p, ssR, rtol);
		soD = fn.SS(mm.odeNF, p, soR, rtol);
		# Restore the original parameter value
		p[pp] /= d;
		return ssD, soD
	end;

	## Compute CoRa 
	function CoRa(ssR, ssD, soR, soD)
		if abs(log10(last(soD)/soR)) < 1e-4
			return NaN
		end
		return abs.(log10.(ssD/ssR)) ./ abs.(log10.(soD/soR));
	end;

	## Compute CoRaDyn
	function CoRaDyn(t, yFB, ssR, yNF, soR, mm)
		# Save the index where the simulation has reached the maximum time given by the user
		i = findfirst(yFB.t .== t)
		j = findfirst(yNF.t .== t)
		print(i, " ", j, "\n")
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
			k = findfirst((logYFB[1:i-1] .* logYFB[2:i]) .<= 0)
			# Take the absolute value of all the differences
			logYFB = abs.(logYFB)
			return (yNF.t[j] * (sum((logYFB[1:i-1] .+ logYFB[2:i]) .* (yFB.t[2:i] .- yFB.t[1:i-1])) - (2 * sum((logYFB[k] .* logYFB[k .+ 1] .* (yFB.t[k .+ 1] .- yFB.t[k])) ./ (logYFB[k] .+ logYFB[k .+ 1]))))) / (yFB.t[i] * sum((logYNF[1:j-1] .+ logYNF[2:j]) .* (yNF.t[2:j] .- yNF.t[1:j-1])))
		end
	end;

	## Simulates dynamics of ODE system over the specified time span
	function Dyn(syst, p, x0, tspan, rtol, saveat, tstops)
		# Extract parameter values
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		# Attempt to solve the ODE problem
		xD = try
			fn.solve(fn.ODEProblem(syst,x0,tspan,pV); saveat = saveat, tstops = tstops, reltol=rtol);
			print(xD)
		catch
			# Retry with stiffness hints if the first solver fails
			try
				fn.solve(fn.ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; saveat = saveat, tstops = tstops, reltol=rtol);
			# On repeated failure, print warning and return NaN vector
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end;
		# If the solver reports an unsuccessful return code, retry with stiffness hints
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
end
