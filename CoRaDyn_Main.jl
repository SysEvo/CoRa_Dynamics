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
		writedlm(io, [vcat("time","Y","Ynf","CoRa",'\t');
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
		writedlm(io, [vcat(0,mm.outFB(fsR),mm.outNF(nsR),1)],'\t');
		for i in collect(0.1:0.1:10000.0)
			writedlm(io, [vcat(i,mm.outFB(fdD(i)),mm.outNF(ndD(i)),fn.CoRa(mm.outFB(fsR),mm.outFB(fdD(i)),mm.outNF(nsR),mm.outNF(ndD(i))))],'\t');
		end
		writedlm(io, [vcat(Inf,mm.outFB(fsD),mm.outNF(nsD),fn.CoRa(mm.outFB(fsR),mm.outFB(fsD),mm.outNF(nsR),mm.outNF(nsD)))],'\t');
	end
else
	println("ERROR: Undetermined analysis. Options: ExDyn")
end
