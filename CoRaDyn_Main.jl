## CoRa DYNAMICS ANALYSIS
#	Mariana Gómez-Schiavon
#	November, 2021
#		Julia v.1.5.3
#		Required libraries:
#			DifferentialEquations
#			ParameterizedFunctions
#			Statistics
#			Distributions
#			DelimitedFiles

## Load functions & parameters:
using DelimitedFiles
using Distributions
mm = include(string("Library\\Md_",iARG.mm,".jl"));
fn = include(string("Library\\FN_CoRaDyn.jl"));
## INPUTS:
# iARG = (mm : Label for motif file, ex : Label for parameters file, pp : Label for perturbation type, an : Chose analysis type);
include(string("InputFiles\\ARGS_",iARG.mm,"_Pert_",iARG.ex,".jl"))	# Perturbation details
include(string("InputFiles\\ARGS_",iARG.mm,"_Par_",iARG.ex,".jl"))	# Core parameters
pO = copy(p);

## Run analysis
# Calculate dynamic response after a perturbation:
if(iARG.an=="ExDyn")
	p = copy(pO);
	open(string("OUT_ExDyn_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,".txt"), "w") do io
		writedlm(io, [vcat("FB","rho","time",[string(i) for i in mm.odeNF.syms])],'\t');
		ssR, soR = fn.RefSS(mm,p,pert,x0FB,x0NF);
		rtol = 1e-12;
		# Feedback system:
		syst = mm.odeFB;
		x = fn.Dyn(syst, p, ssR, 500.0, rtol);
		if(any(isnan.(x)))
			writedlm(io, [vcat(1,p[iARG.pp],0,x,"NaN")],'\t');
		end
		for i in 1:length(x.t)
			writedlm(io, [vcat(1,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
		end
		p[pert.p] *= pert.d;
		x = fn.Dyn(syst, p, last(x.u), 95000.0, rtol);
		if(any(isnan.(x)))
			writedlm(io, [vcat(1,p[iARG.pp],500.0,x,"NaN")],'\t');
		end
		for i in 1:length(x.t)
			writedlm(io, [vcat(1,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
		end
		ssD = fn.SS(syst, p, ssR, rtol);
		writedlm(io, [vcat(1,p[iARG.pp],"Inf",ssD,"NaN")],'\t');
		p[pert.p] /= pert.d;
		# No-Feedback system:
		syst = mm.odeNF;
		x = fn.Dyn(syst, p, soR, 500.0, rtol);
		if(any(isnan.(x)))
			writedlm(io, [vcat(0,p[iARG.pp],0,x)],'\t');
		end
		for i in 1:length(x.t)
			writedlm(io, [vcat(0,p[iARG.pp],x.t[i],x.u[i])],'\t');
		end
		p[pert.p] *= pert.d;
		x = fn.Dyn(syst, p, last(x.u), 95000.0, rtol);
		if(any(isnan.(x)))
			writedlm(io, [vcat(0,p[iARG.pp],500.0,x)],'\t');
		end
		for i in 1:length(x.t)
			writedlm(io, [vcat(0,p[iARG.pp],x.t[i]+500.0,x.u[i])],'\t');
		end
		soD = fn.SS(syst, p, soR, rtol);
		writedlm(io, [vcat(0,p[iARG.pp],"Inf",soD)],'\t');
		p[pert.p] /= pert.d;
	end
else
	println("ERROR: Undetermined analysis. Options: ExDyn")
end
