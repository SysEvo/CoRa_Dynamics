# Smallest chemical reaction system 
#   showing a Hopf bifurcation (i.e. minimal oscillator)
# A → controlled species of interest

# Julia v 1.8.2

module mm
        # Required libraries 
        using DifferentialEquations
        using ParameterizedFunctions

        # ODE system
        odeFB = @ode_def begin 
            dGp = ((Vmax * Ge * Gp)/(Km + Gp)) - (k4 * Gp) - (k2 * A * Gp) + (km2 * A) + (km4 * Gi)
            dGi = (k4 * Gp) - (k5 * Gi) - (km4 * Gi) + (km5 * A)
            dA = - (k3 * A) + (k5 * Gi) - (km5 * A)
        end Vmax Ge Km k2 k3 k4 k5 km2 km4 km5 

        # ODE system without feedback
        odeNF = @ode_def begin 
            dGp = ((Vmax * Ge * Gp)/(Km + Gp)) - (k4 * Gp) - (k6 * Gp) + (km2 * A) + (km4 * Gi)
            dGi = (k4 * Gp) - (k5 * Gi) - (km4 * Gi) + (km5 * A)
            dA = - (k3 * A) + (k5 * Gi) - (km5 * A)
        end Vmax Ge Km k2 k3 k4 k5 k6 km2 km4 km5 

        # Define system's output (total A):
        function outFB(ss)
            return ss[3];
        end;
        function outNF(ss)
            return ss[3];
        end;

        # Get the timeseries for A:
        function solFB(dyn)
            return dyn[3,:]
        end;
        function solNF(dyn)
            return dyn[3,:]
        end;

        # Define locally analogous system:
        function localNF(p,ss)
            p[:k6] = p[:k2] * ss[3];
        end;
end
       