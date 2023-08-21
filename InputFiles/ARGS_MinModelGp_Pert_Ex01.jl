# Perturbation details
pert = (p   = iARG.pp,		# Parameter to be perturbed
		d   = 1.05,		# Perturbation size (Delta rho)
		c   = iARG.ax,		# Condition parameter
		r   = [5,35],		# Range of conditions
		s   = 5,			# Step
		eps = 0.1,			# CoRa threshold
		tspan = 2000, 	# tspan over which CoRa will be evaluated
		saveat = [],
		pt = 500,
		maxiters = Int(1e6));		# Specific times to save the dynamic at