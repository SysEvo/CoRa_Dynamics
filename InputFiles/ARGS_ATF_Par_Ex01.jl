# Kinetic parameters
p = Dict([
    :bI => 0.06, # min-1
    :mY => 1 * 60, # min-1 nM 
    :n => 0.01, # nM-1 min-1
    :gZ1 => 0, # nM min-1 [0.0301,0.0408]
    :gZ2 => 0, # nM min-1 [0.0301,0.0408]
    :theta => 0.3, # min-1
    :g1 => 0.1, # min-1 
    :bC => 0.2*1.05, # min-1 [0.01,0.05565,0.1,0.106]
    :gC => 0.1 # nM
]);

#Inital conditions
x0 = ones(length(mm.odeFB.syms));