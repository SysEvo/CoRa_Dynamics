## Running in julia terminal
       cd("/Users/athenatmyo4/Desktop/CoRaDyn/CoRaDyn_Paper") 
       
       using Pkg; 
       using BenchmarkTools

       Pkg.activate(".");		       # Activate local environment (requiere '.toml' files)
	iARG = (mm = "PID",                # Label for motif file
       ex = "Fig3F",                       # Label for parameter and perturbation file
       pp = :bC,                          # Parameter on which the perturbation will be applied
       ax = [:bP, :bD],                        # Parameters that will be varied (e.g. condition/environment)
       an = "ExMultiCoRaDyn");                 # Chose analysis type (Options: ExCoRa, ExCoRaDyn, ExCoRaDyn_tspan, ExMultiCoRaDyn, ExDyn)
       include("./CoRaDyn_Main_v1.jl");