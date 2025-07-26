## Running in julia terminal
       #cd("/home/atamayo/Desktop/Mariana/Final") 
       
       using Pkg; 
       #using BenchmarkTools

       Pkg.activate(".");		    # Activate local environment (requiere '.toml' files)
	iARG = (mm = "PID",             # Label for motif file
       ex = "Fig03A",                    # Label for parameters file
       pp = :bC,                       # Label for perturbation type
       ax = [],                 # Label for condition/environment [:bP, :bD]
       an = "ExDyn");        # Chose analysis type (Options: ExSSs, ExDyn, CoRams, OptDY)
       include("./CoRaDyn_Main_v1.jl");
