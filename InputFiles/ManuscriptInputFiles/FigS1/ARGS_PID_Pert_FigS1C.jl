# Perturbation details
pert = (p   = iARG.pp,        # Parameter to be perturbed
        d   = [1.01, 1.02, 1.03, 1.04, 1.05],         # Perturbation size (Delta rho)
        c   = iARG.ax,        # Parameters that will be varied (e.g. condition/environment)
        r   =  [[0, 0.1]],  # Value ranges for each parameter to be varied 
        s   =  5,         # Length of the parameter ranges 
        tspan = 500, # Evaluation times. Provide a specific time point, a time vector, or a minimum and maximum to create a range
        l = NaN,            # Length of time range (if applicable)
        tlog = false,         # Set to true to generate the time range using a log scale
        saveat = []);		# List of specific time points at which the system dynamics should be saved

	