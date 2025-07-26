# Perturbation details
pert = (p   = iARG.pp,		# Parameter to be perturbed
		d   = 1.05, 		# Perturbation size (Delta rho)
		c   = iARG.ax,		# Condition parameter
		r   =  [[0,0.5],[0.02,0.1],[0,0.8]],   # Range of conditions
		s   =  [5,5,5],              # Step or length 
		eps = 0.08,             # CoRa threshold
		tspan = 500,         # Time range over which CoRa will be evaluated
		l = 1,			# Step or length [27, 27]
		saveat = [],		# List of specific times that indicate when the dynamics should be saved
		tstops = [],
		pt = NaN,
		maxiters = Int(1e8));

	