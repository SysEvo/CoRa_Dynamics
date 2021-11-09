# Steady state & CoRa calculation functions
#		Julia v.1.5.3

module fn
	# Required libraries
	using DifferentialEquations
	using ParameterizedFunctions
	using Statistics

	# Steady state function for a given system
	# INPUT: syst - Handle for the ODE system (@ode_def)
	#        p    - Dictionary function with the ODE parameters & values
	#        x0   - Vector of initial state of the ODE system
	#        rtol - Tolerance value for ODE solver
	# OUTPUT: ss   - Vector of steady state of the ODE system
	function SS(syst,p,x0,rtol)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		tS = 0;
		dXrm = 1;
		while(dXrm > rtol)
			ss = try
				solve(ODEProblem(syst,x0,1e6,pV); reltol=rtol,save_everystep = false);
			catch
				try
					solve(ODEProblem(syst,x0,1e6,pV),alg_hints=[:stiff]; reltol=rtol,save_everystep = false);
				catch err
					println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
					x0 = zeros(length(syst.syms)).+NaN;
					break
				end
			end;
			dXrm = maximum(abs.(big.(ss(1e6))-big.(ss(1e6-0.01)))./big.(ss(1e6)));
			x0 = ss(1e6);
			tS += 1e6;
			if(tS>=1e12)
				println("WARNING: Maximum iteration reached (simulated time 1e18). Max relative Delta: ",dXrm)
				break
			end
			if(any(x0.<0))
				println("WARNING: Error in ODE simulation: Negative values. ss --> NaN")
				x0 = zeros(length(syst.syms)).+NaN;
				break
			end
		end
		return x0
	end;

	# Get (pre-perturbation) reference steady-states:
	# INPUT: mm   - Handle for the full ODE model (with mm.odeFB and mm.odeNF)
	#        p    - Dictionary function with the ODE parameters & values
	#        pert - Dictionary function with perturbation instructions
	#        x0FB - Vector of initial state of the ODE feedback system
	#        x0NF - Vector of initial state of the ODE no-feedback system
	# OUTPUT: ssR - Vector of steady state of the ODE system feedback system
	#         soR - Vector of steady state of the ODE system no-feedback system
	function RefSS(mm,p,pert,x0FB,x0NF)
		rtol = 1e-12;
		ssR = zeros(length(mm.odeFB.syms)).+NaN;
		soR = zeros(length(mm.odeNF.syms)).+NaN;
		while(rtol >= 1e-24)
			# Reference steady state:
			ssR = fn.SS(mm.odeFB, p, x0FB, rtol);
			if(any(isnan.(ssR)))
				ssR = zeros(length(mm.odeFB.syms)).+NaN;
				soR = zeros(length(mm.odeNF.syms)).+NaN;
				println("Condition excluded! ssR --> NaN");
				break;
			end
			# Locally analogous system reference steady state:
			mm.localNF(p,ssR);
			soR = fn.SS(mm.odeNF, p, x0NF, rtol);
			if(any(isnan.(soR)))
				ssR = zeros(length(mm.odeFB.syms)).+NaN;
				soR = zeros(length(mm.odeNF.syms)).+NaN;
				println("Condition excluded! soR --> NaN");
				break;
			end
			if(abs(mm.outFB(ssR) - mm.outNF(soR)) > 1e-4)
				rtol *= 1e-3;
				if(rtol < 1e-24)
					println("ERROR: Check NF system (reltol=",rtol,").")
					println(vcat(pert.p,i,[p[eval(Meta.parse(string(":",i)))] for i in mm.odeFB.sys.ps],mm.outFB(ssR),mm.outNF(soR)))
					if(abs(mm.outFB(ssR) - mm.outNF(soR))/mm.outFB(ssR) > 0.01)
						ssR = zeros(length(mm.odeFB.syms)).+NaN;
						soR = zeros(length(mm.odeNF.syms)).+NaN;
						println("Error too large. SS results excluded!")
					end
				end
			else
				break
			end
		end
		return ssR, soR
	end;

	# Get (post-) perturbation steady-states:
	# INPUT: mm   - Handle for the full ODE model (with mm.odeFB and mm.odeNF)
	#        p    - Dictionary function with the ODE parameters & values
	#        pert - Dictionary function with perturbation instructions
	#        ssR  - Vector of pre-perturbation steady-state of the ODE feedback system
	#        soR  - Vector of pre-perturbation steady-state of the ODE no-feedback system
	# OUTPUT: ssD - Vector of steady state of the ODE system feedback system
	#         soD - Vector of steady state of the ODE system no-feedback system
	function PerSS(mm,p,pert,ssR,soR)
		rtol = 1e-12;
		p[pert.p] *= pert.d;
		ssD = fn.SS(mm.odeFB, p, ssR, rtol);
		soD = fn.SS(mm.odeNF, p, soR, rtol);
		p[pert.p] /= pert.d;
		return ssD, soD
	end;

	# ODE dynamics for a given system
	# INPUT: syst - Handle for the ODE system (@ode_def)
	#        p    - Dictionary function with the ODE parameters & values
	#        x0   - Vector of initial state of the ODE system
	#        tspan- Time to simulate
	#        rtol - Tolerance value for ODE solver
	# OUPUT: xD   - Vector of steady state of the ODE system
	function Dyn(syst,p,x0,tspan,rtol)
		pV = [p[eval(Meta.parse(string(":",i)))] for i in syst.sys.ps];
		xD = try
			solve(ODEProblem(syst,x0,tspan,pV); reltol=rtol);
		catch
			try
				solve(ODEProblem(syst,x0,tspan,pV),alg_hints=[:stiff]; reltol=rtol);
			catch err
				println("WARNING: Error in ODE simulation: <<",err,">>. ss --> NaN")
				zeros(length(syst.syms)).+NaN;
			end
		end;
		return xD
	end;

	# CoRa function
	# INPUT: Y    - Output of full system before perturbation
	#        YD   - Output of full system after perturbation
	#        Ynf  - Output of non-feedback system before perturbation (Ynf:=Y)
	#        YnfD - Output of non-feedback system after perturbation
	# OUPUT:      - DY value
	function CoRa(Y,YD,Ynf,YnfD)
		if abs(log10(YnfD/Ynf)) < 1e-4
			return NaN
		end
		return log10(YD/Y)/log10(YnfD/Ynf);
	end;
end
