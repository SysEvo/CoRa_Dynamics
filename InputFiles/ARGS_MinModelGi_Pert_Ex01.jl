# Perturbation details
pert = (p   = iARG.pp,	# Parameter to be perturbed
		d   = 1.05,		# Perturbation size (Delta rho)
		c   = iARG.ax,	# Condition parameter
		r   = [2,23],	# Range of conditions
		s   = 0.01,		# Step
		eps = 0.1,		# CoRa threshold
		tspan = 95500.0, 	# tspan over which CoRa will be evaluated
		saveat = []);		# Specific times to save the dynamic at