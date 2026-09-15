# Kinetic parameters
p = Dict([
    :mu => 1, # min-1
    :Y => 300, # nM
    :n => 0.01, # nM-1 min-1
    :theta => 0.3, # min-1
    :bA => 1.5, # min-1
    :bI => 0.06, # min-1
    :bC => 0.1, # min-1 [0.01,0.05565,0.1,0.106]
    :bD => 0.0, # min-1
    :bP => 0.0, # min-1
    :bM => 0.4167, # min-1
    :g1 => 0.1, # min-1 
    :gA => 1.5, # min-1
    :gC => 0.1, # min-1
    :gD => NaN, # 0.01 min-1
    :gM => 1.5, # min-1
    :gA0 => 0.1, # min-1
    :KA => 1, # nM
    :KM => 1, # nM
    :k0 => NaN, # min-1 nM
]);

#Inital conditions
x0 = ones(length(mm.odeFB.syms));

