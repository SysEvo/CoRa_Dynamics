# Perturbation details
pert = (p   = iARG.pp,	# Parameter to be perturbed
		d   = 1.05,		# Perturbation size (Delta rho)
		c   = iARG.ax,	# Condition parameter
		r   = [0.01, 0.3],	# Range of conditions
		s   =  7,		# Step or length
		eps = 0.1,		# CoRa threshold
		tspan = 2000, 	# Time range over which CoRa will be evaluated
		saveat = [],		# List of specific times that indicate when the dynamics should be saved
		pt = 500,
		maxiters = Int(1e6));