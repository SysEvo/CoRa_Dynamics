## Running in julia terminal
       cd("/home/atamayo/Desktop/Mariana/Final") 
       
       using Pkg; 
       using BenchmarkTools

       Pkg.activate(".");		       # Activate local environment (requiere '.toml' files)
	iARG = (mm = "PID",                # Label for motif file
       ex = "Ex01",                       # Label for parameter and perturbation file
       pp = :bC,                          # Parameter on which the perturbation will be applied
       ax = [:bD],                        # Parameters that will be varied (e.g. condition/environment)
       an = "ExCoRaDyn");                 # Chose analysis type (Options: ExCoRa, ExCoRaDyn, ExCoRaDyn_tspan, ExMultiCoRaDyn, ExDyn)
       include("./CoRaDyn_Main_v1.jl");
