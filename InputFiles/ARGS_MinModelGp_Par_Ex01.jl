p = Dict([
    :Ge => 31.52631578947368,     # Glutamate concentration in the environment (mmol l−1)
    :k1 => 0.34,      # Rate constant of glutamate diffusion from environment to bioﬁlm (mmol l−1 h)−1
    :k2 => 5.3,       # Biomass formation coefﬁcient (mmol l−1 h)−1
    :km2 => 5.3,      # Biomass degradation coefﬁcient (mmol l−1 h)−1
    :k3 => 4.0,         # Rate constant of ammonia diffusion (h−1)
    :k4 => 2.0,         # Rate constant of glutamate diffusion within bioﬁlm (h−1)
    :km4 => 2.0,        # Reverse diffusion rate constant of glutamate within the biofilm (h−1)
    :k5 => 2.3,       # Ammonia production coefﬁcient (h−1)
    :km5 => 2.3,      # Glutamate production coefﬁcient (h−1)
    :k6 => NaN,       # LOCAL: As constitutive synthesis rate (h−1)
    :Km => 1100.0,      # Michaelis-Menten constant (mmol/l)
    :Vmax => 1400.0,    # Maximum glutamate uptake rate at saturating concentration (mmol/lh)
]);

#Inital conditions
x0 = ones(length(mm.odeFB.syms));