# Perturbation details
pert = (p   = iARG.pp,        # Parameter to be perturbed
        d   = 1.05,         # Perturbation size (Delta rho)
        c   = iARG.ax,        # Parameters that will be varied (e.g. condition/environment)
        r   =  [[0, 0.5], [0, 0.185]],  # Value ranges for each parameter to be varied 
        s   =  [2, 2],         # Length of the parameter ranges 
        tspan = [0.1, 8000], # Evaluation times. Provide a specific time point, a time vector, or a minimum and maximum to create a range
        l = 251,            # Length of time range (if applicable)
        tlog = true,         # Set to true to generate the time range using a log scale
        saveat = []);		# List of specific time points at which the system dynamics should be saved

	