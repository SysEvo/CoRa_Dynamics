# Perturbation details
pert = (p   = iARG.pp,								# Parameter to be perturbed
		d   = 1.05, 								# Perturbation size (Delta rho)
		c   = iARG.ax,								# Parameters that will be varied (e.g. condition/environment)
		r   =  [[0, 0.5], [0, 0.8], [0.02, 0.1]],	# Value ranges for each parameter to be varied 
		s   =  [25, 25, 25], 						# Length of the parameter ranges 
													# Evaluation times. Provide a specific time point, a time vector, or a minimum and maximum to create a range
		tspan = [15, 20, 25, 30, 50, 75, 100, 250, 500, 750, 1000, 3000],        
		l = 12, 									# Length of time range (if applicable)
		tlog = false,  								# Set to true to generate the time range using a log scale
		saveat = []);        						# List of specific time points at which the system dynamics should be saved
	