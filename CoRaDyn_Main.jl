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
	open(string("OUT_ExDyn_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,".txt"), "w") do io
		writedlm(io, [vcat("time","Y","Ynf","CoRa")],'\t');
		p = copy(pO);
		# Start in steady state conditions
		fsR, nsR = fn.RefSS(mm,p,pert,x0FB,x0NF);
		rtol = 1e-12;
		# Simulate dynamic response after the perturbation:
		p[pert.p] *= pert.d;
		fdD = fn.Dyn(mm.odeFB, p, fsR, 100000.0, rtol);
		fsD = fn.SS(mm.odeFB, p, fsR, rtol);
		ndD = fn.Dyn(mm.odeNF, p, nsR, 100000.0, rtol);
		nsD = fn.SS(mm.odeNF, p, nsR, rtol);
		p[pert.p] /= pert.d;
		# Calculate and print CoRa:
		fyR = mm.outFB(fsR);
		nyR = mm.outNF(nsR);
		writedlm(io, [vcat(0,fyR,nyR,1)],'\t');
		for i in collect(0.1:0.1:10000.0)
			fyD = mm.outFB(fdD(i));
			nyD = mm.outNF(ndD(i));
			writedlm(io, [vcat(i,fyD,nyD,fn.CoRa(fyR,fyD,nyR,nyD))],'\t');
		end
		fyF = mm.outFB(fsD);
		nyF = mm.outNF(nsD);
		writedlm(io, [vcat(Inf,fyF,nyF,fn.CoRa(fyR,fyF,nyR,nyF))],'\t');
	end
elseif(iARG.an=="msDyn")
	open(string("OUT_msDyn_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,".txt"), "w") do io
		writedlm(io, [vcat("theta","time","Y","Ynf","CoRa")],'\t');
		# Range of parameters to explore:
		r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        for i in 1:length(r)
			p = copy(pO);
			# Condition (theta) to evaluate:
			p[pert.c] *= r[i];
			# Start in steady state conditions
			fsR, nsR = fn.RefSS(mm,p,pert,x0FB,x0NF);
			rtol = 1e-12;
			# Simulate dynamic response after the perturbation:
			p[pert.p] *= pert.d;
			fdD = fn.Dyn(mm.odeFB, p, fsR, 100000.0, rtol);
			fsD = fn.SS(mm.odeFB, p, fsR, rtol);
			ndD = fn.Dyn(mm.odeNF, p, nsR, 100000.0, rtol);
			nsD = fn.SS(mm.odeNF, p, nsR, rtol);
			p[pert.p] /= pert.d;
			# Calculate and print CoRa:
			fyR = mm.outFB(fsR);
			nyR = mm.outNF(nsR);
			writedlm(io, [vcat(p[pert.c],0,fyR,nyR,1)],'\t');
			fyF = mm.outFB(fsD);
			nyF = mm.outNF(nsD);
			for i in collect(0.1:0.1:10000.0)
				fyD = mm.outFB(fdD(i));
				nyD = mm.outNF(ndD(i));
				writedlm(io, [vcat(p[pert.c],i,fyD,nyD,fn.CoRa(fyR,fyD,nyR,nyD))],'\t');
				if(max(abs(fyD-fyF),abs(nyD-nyF))<1e-8)
					break;
				end
			end
			writedlm(io, [vcat(p[pert.c],Inf,fyF,nyF,fn.CoRa(fyR,fyF,nyR,nyF))],'\t');
		end
	end
else
	println("ERROR: Undetermined analysis. Options: ExDyn, msDyn")
end
