# Antithetic feedback (v01)
#   with inactive W in complex form

# Julia v.1.1.1

module mm
	# Required libraries
	using DifferentialEquations
	using ParameterizedFunctions
	using Symbolics

	# ODE system
	odeFB = @ode_def begin 
		dZ1 =        mY    - (n * Z1 * Z2) - (gZ1 * Z1)
		dZ2 = (theta * XC) - (n * Z1 * Z2) - (gZ2 * Z2)
		dX1 =    (bI * Z1) - (g1 * X1)
		dXC =    (bC * X1) - (gC * XC)
	end mY n theta bI g1 bC gC gZ1 gZ2;

	function f(t, solFBR)
		return solFBR(t)[4]
	end

	xc(t) = f(t, solFBR)
	@register_symbolic xc(t)

	# ODE system without feedback
	odeNF = @ode_def begin 
		dZ1 =        mY    - (n * Z1 * Z2)
		dZ2 = 	(theta * xc(t)) - (n * Z1 * Z2)
		dX1 =    (bI * Z1) - (g1 * X1)
		dXC =    (bC * X1) - (gC * XC)
	end mY n theta bI g1 bC gC gZ1 gZ2;

	#= odeNF = @ode_def begin 
		dZ1 =        mY    - (n * Z1 * Z2)
		dZ2 = 		bZ2 - (n * Z1 * Z2)
		dX1 =    (bI * Z1) - (g1 * X1)
		dXC =    (bC * X1) - (gC * XC)
	end mY n bZ2 bI g1 bC gC gZ1 gZ2; =#

	# Define system's output (total Y):
	function outFB(ss)
		return ss[4];
	end;
	function outNF(ss)
		return ss[4];
	end;

	# Get the timeseries for Gi:
	function solFB(sol)
		return sol[4,:]
	end;
	function solNF(sol)
		return sol[4,:]
	end;
        
	# Define locally analogous system:
	function localNF(p,ss)
		p[:bZ2] = p[:theta] * ss[4];
	end;

end