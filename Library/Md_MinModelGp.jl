# Smallest chemical reaction system 
#   showing a Hopf bifurcation (i.e. minimal oscillator)
# Gp → controlled species of interest

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

        # External function to calculate k6
        function f(t)
            return solFBR(t)[1]
        end

        k6(t) = f(t)
        @register_symbolic k6(t)

        # ODE system without feedback
        odeNF = @ode_def begin
            dGp = ((Vmax * Ge * Gp)/(Km + Gp)) - (k4 * k6(t)) - (k2 * A * Gp) + (km2 * A) + (km4 * Gi)
            dGi = (k4 * k6(t)) - (k5 * Gi) - (km4 * Gi) + (km5 * A)
            dA = - (k3 * A) + (k5 * Gi) - (km5 * A)
        end Vmax Ge Km k2 k3 k4 k5 km2 km4 km5

        # Define system's output (total Gp):
        function outFB(ss)
            return ss[1];
        end;
        function outNF(ss)
            return ss[1];
        end;

        # Get the timeseries for Gp:
        function solFB(dyn)
            return dyn[1,:]
        end;
        function solNF(dyn)
            return dyn[1,:]
        end;

        # Define locally analogous system:
        function localNF(p,ss)
            p[:k6] = p[:k4] * ss[1];
        end;
end
           