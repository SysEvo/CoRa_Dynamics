# Perturbation details
pert = (p   = iARG.pp,		# Parameter to be perturbed
		d   = 1.05, 		# Perturbation size (Delta rho)
		c   = iARG.ax,		# Condition parameter
		r   =  [NaN, NaN],   # Range of conditions
		s   =  NaN,              # Step or length 
		eps = 0.08,             # CoRa threshold
		tspan = 8000,         # Time range over which CoRa will be evaluated
		l = NaN,			# Step or length [27, 27]
		saveat = [],		# List of specific times that indicate when the dynamics should be saved
		tstops = [],
		pt = NaN,
		maxiters = Int(1e8));

	