# Perturbation details
pert = (p   = iARG.pp,		# Parameter to be perturbed
		d   = 1.05, 		# Perturbation size (Delta rho)
		c   = iARG.ax,		# Condition parameter
		r   =  [[0, 0.5], [0, 0.8], [0.02, 0.1]],
		s   =  [25, 25, 25],
		eps = 0.08,            # CoRa threshold
		tspan = [15, 20, 25, 30, 50, 75, 100, 250, 500, 750, 1000, 3000],        
		l = 12,
		saveat = [],        # List of specific times that indicate when the dynamics should be saved
		tstops = [],
		pt = NaN,
		maxiters = Int(1e8));

	