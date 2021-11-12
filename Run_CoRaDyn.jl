## Running in julia terminal
	cd("C:\\Users\\mgsch\\Dropbox (Personal)\\LIIGH\\PROJECT - CoRa dynamics\\CoRa_Dynamics\\")
	using Pkg; Pkg.activate(".");
	iARG = (mm = "ATFv1",  # Label for motif file
       ex = "Ex01",      # Label for parameters file
       pp = :mY,         # Label for perturbation type
       ax = :mY,         # Label for condition/environment
       an = "msDyn");    # Chose analysis type (Options: ExDyn, msDyn)
	include("CoRaDyn_Main.jl")
