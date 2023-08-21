## Running in julia terminal
       cd("/home/atamayo/Desktop/Mariana/CoRa")    

       using Pkg; 
       using BenchmarkTools

       Pkg.activate(".");		       # Activate local environment (requiere '.toml' files)
	iARG = (mm = "ATF",            # Label for motif file
       ex = "Ex01",                       # Label for parameters file
       pp = :bC,                          # Label for perturbation type
       ax = :bC,                          # Label for condition/environment
       an = "ExCoRaDyn");                     # Chose analysis type (Options: ExSSs, ExDyn, CoRams, OptDY)
	include("CoRaDyn_Main_v1.0.jl");
