# Functions for CoRaDyn analysis
#		Julia v.1.6

module fn 
	using DifferentialEquations

	function x0(syst, x0, p)
		return fn.Dyn(syst, p, x0, 1e6, 1e-12, [], [], nothing, Int(1e8), false).u[end];
	end;

	function PertCallback(p, d, pt, mm)
		affect!(integrator) = integrator.p[findfirst((Symbol.(mm.odeFB.sys.ps) .== p).value)] *= d
		return PresetTimeCallback(pt, affect!, save_positions = (false,false))
	end;

	# Function that verifies that the dynamics of both feedback and non-feedback systems are synchronized before the perturbation
	function CheckSync(DynFBR, DynFB, DynNF, t, mm)
		i = findfirst(DynFBR.t .== t)
		err = abs.(hcat(mm.solFB(DynFBR)[1:i] .- mm.solFB(DynFB(DynFBR.t))[1:i], mm.solFB(DynFBR)[1:i] .- mm.solNF(DynNF(DynFBR.t))[1:i], mm.solFB(DynFB(DynFBR.t))[1:i] .- mm.solNF(DynNF(DynFBR.t))[1:i]))
		if any(err .> 1e-4)
			println("\n", "Error: The reference dynamics are out of sync. Results excluded!", " Error size = ", err[err .> 1e-4], " at times ", DynFBR.t[first.(Tuple.(findall(err .> 1e-4)))],".")
			return true
		else 
			println("\n", "The reference dynamics are synchronized!")
			return false
		end
	end;

	function Dyn(syst, p, x0, tspan, rtol, saveat, tstops, cb, maxiters, save_everystep)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		xD = try
			fn.solve(fn.ODEProblem(syst,x0,tspan,pV); saveat = saveat, tstops = tstops, reltol=rtol, callback = cb, maxiters = maxiters, save_everystep = save_everystep);
		catch
			try
				fn.solve(fn.ODEProblem(syst,x0,tspan,pV),KenCarp4(); saveat = saveat, tstops = tstops, reltol=rtol, callback = cb, maxiters = maxiters, save_everystep = save_everystep);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end;
		if xD.retcode == :Unstable
			try
				xD = fn.solve(fn.ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; saveat = saveat, tstops = tstops, reltol=rtol, callback = cb, maxiters = maxiters, save_everystep = save_everystep);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end
		return(xD)
	end;

	function x0andCheckSync(mm, x0, p, pt)
		syst = mm.odeFB
		x0 .= fn.x0(syst, x0, p)
		global DynFBR = fn.Dyn(syst, p, x0, pt[end], 1e-12, [], pt, nothing, Int(1e6), true);
		@eval mm solFBR = Main.fn.DynFBR
		DynFB = fn.Dyn(syst, p, x0, pt[end], 1e-12, [], [], nothing, Int(1e6), true);
		syst = mm.odeNF
		DynNF = fn.Dyn(syst, p, x0, pt[end], 1e-12, [], [], nothing, Int(1e6), true);
		syncFlag = fn.CheckSync(DynFBR, DynFB, DynNF, pt[end], mm)
		x0s = DynFBR.u[indexin(pt, DynFBR.t)]
		return syncFlag, x0s
	end;

	function CoRaDynOsc(t, tspan, DynFBR, DynFB, DynNF, mm)
		# Save the index where the simulation has reached the perturbation and simulation time given by the user
		tspan = tspan - t 
		i, j, k = findfirst(DynFB.t .== tspan), findfirst(DynNF.t .== tspan), findfirst(DynFBR.t .== tspan)
		# Display a warning if one of the simulations did not reach the specified tspan
		if any([i, j, k] .== nothing)
			println("\n","WARNING: Error in ODE simulation:", ["DynFB", "DynNF", "DynFBR"][findall([i,j,k] .== nothing)],"not reaching the specified tspan.")
		end
		tFB = sort(vcat(DynFB.t[1:i], DynFBR.t[1:k]))
		tNF = sort(vcat(DynNF.t[1:j], DynFBR.t[1:k]))
		# Check if the log difference between the post and pre perturbation states of the system without feedback reaches negative values
		if any(log10.(mm.solNF(DynNF(tNF)) ./ mm.solNF(DynFBR(tNF))) .< 0)
			NFflag = "TRUE"
		else 
			NFflag = "FALSE"
		end
		# Calculate the logarithmic difference between the post and pre perturbation states of the system with feedback
		logFB = log10.(mm.solFB(DynFB(tFB)) ./ mm.solFB(DynFBR(tFB)))
		# Check if the difference reaches negative values
		if	all(logFB .>= 0)
			# If it does not, calculate CoRaDyn	
			FBflag = "FALSE"
			FBarea = sum((logFB[1:end-1] .+ logFB[2:end]) .* (tFB[2:end] .- tFB[1:end-1]))
			NFarea = sum(log10.(mm.solNF(DynNF(tNF))[1:end-1] .* mm.solNF(DynNF(tNF))[2:end] ./ (mm.solNF(DynFBR(tNF))[1:end-1] .* mm.solNF(DynFBR(tNF))[2:end])) .* (tNF[2:end] .- tNF[1:end-1]))									
			CoRaDynOsc = (tNF[end] * FBarea) / (tFB[end] * NFarea)
			return CoRaDynOsc, FBflag, NFflag, FBarea, NFarea
		else
			# If the difference reaches negative values, calculate CoRaDyn in such a way that it removes part of the error
			FBflag = "TRUE"
			# Get the indexes where the error occurs
			l = findall((logFB[1:end-1] .* logFB[2:end]) .< 0)
			# Take the absolute value of all the differences
			logFB .= abs.(logFB)
			FBarea = (sum((logFB[1:end-1] .+ logFB[2:end]) .* (tFB[2:end] .- tFB[1:end-1])) - (2 * sum((logFB[l] .* logFB[l .+ 1] .* (tFB[l .+ 1] .- tFB[l])) ./ (logFB[l] .+ logFB[l .+ 1]))))
			NFarea = sum(log10.(mm.solNF(DynNF(tNF))[1:end-1] .* mm.solNF(DynNF(tNF))[2:end] ./ (mm.solFB(DynFBR(tNF))[1:end-1] .* mm.solFB(DynFBR(tNF))[2:end])) .* (tNF[2:end] .- tNF[1:end-1]))
			CoRaDynOsc = (tNF[end] * FBarea) / (tFB[end] * NFarea)
			return CoRaDynOsc, FBflag, NFflag, FBarea, NFarea
		end
	end;
end;