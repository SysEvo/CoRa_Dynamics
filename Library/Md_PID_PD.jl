# Antithetic feedback (v01)
#   with inactive W in complex form

# Julia v 1.8.5

module mm
        # Required libraries 
        using DifferentialEquations
        using ParameterizedFunctions

        # ODE system
        odeFB = @ode_def begin 
            dZ1 =    (mu * Y)   - (n * Z1 * Z2) - (gD * Z1)
			dZ2 = (theta * XC) - (n * Z1 * Z2) - (gD * Z2)
            dX1 =    (bI * Z1) + ((bP * Y * mu * Y) / ((mu * Y) + (theta * XC))) + (bD * A) - (g1 * X1) - (gD * X1)
            dXC =    (bC * X1) - (gC * XC) - (gD * XC)
            dA  =    (bA * M)  - ((gA * XC * A) / (KA + A)) - (gA0 * A) - (gD * A)
            dM  =    (bM * Y)  - ((gM * A  * M) / (KM + M)) - (gD  * M) 
        end mu Y n theta bA bI bC bD bP bM g1 gA gC gD gM gA0 KA KM

        # ODE system without feedback 
        odeNF = @ode_def begin 
            dZ1 =    (mu * Y)   - (n * Z1 * Z2) - (gD * Z1)
			dZ2 = (theta * XC) - (n * Z1 * Z2) - (gD * Z2)
            dX1 =    (bI * Z1) + ((bP * Y * mu * Y) / ((mu * Y) + (k01))) + (k02) - (g1 * X1) - (gD * X1)
            dXC =    (bC * X1) - (gC * XC) - (gD * XC)
            dA  =    (bA * M)  - ((gA * XC * A) / (KA + A)) - (gA0 * A) - (gD * A)
            dM  =    (bM * Y)  - ((gM * A  * M) / (KM + M)) - (gD  * M) 
        end mu Y n theta bA bI bC bD bP bM g1 gA gC gD gM gA0 KA KM k01 k02

        # Define system's output (total XC):
        function outFB(ss);
            return ss[4];
        end;
        function outNF(ss);
            return ss[4];
        end;

        # Get the timeseries for XC:
        function solFB(dyn)
            return dyn[4,:]
        end;
        function solNF(dyn)
            return dyn[4,:]
        end;

        # Define locally analogous system:
        function localNF(p, ss)
            p[:k01] = p[:theta] * ss[4] 
            p[:k02] = p[:bD] * ss[5] 
        end;
end