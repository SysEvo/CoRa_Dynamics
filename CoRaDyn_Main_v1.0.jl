###CoRa_v1.0

using DelimitedFiles
using Distributions
using DifferentialEquations
using Plots

#This includes the model to study itself, it must be prepared before running CoRaDyn, with the explicit constraint that the number of d/dt are the same in the FB and NF equations
mm = include(string("Library/Md_",iARG.mm,".jl"));
###This next line is changed to use the "updated" functions .jl
fn = include(string("Library/FN_CoRaDyn.jl"));
## INPUTS:
# iARG = (mm : Label for motif file, ex : Label for parameters file, pp : Label for perturbation type, an : Chose analysis type);
include(string("InputFiles/ARGS_",iARG.mm,"_Pert_",iARG.ex,".jl"))	# Perturbation details
include(string("InputFiles/ARGS_",iARG.mm,"_Par_",iARG.ex,".jl"))	# Core parameters

# Function to obtain the dynamics of a system in response to a perturbation applied at different times (pt) - uses callbacks
if(iARG.an == "ExDynOsc")
    syst = mm.odeFB
    x0 .= fn.x0(syst, x0, p)
    global solFBR = fn.Dyn(syst, p, x0, pert.tspan, 1e-12, pert.saveat, pert.pt, nothing, pert.maxiters, true);
    @eval mm solFBR = Main.solFBR
    for t in pert.pt
        open(string("OutputFiles/OUT_", iARG.an,"_", iARG.mm,"_", iARG.ex,"_", iARG.pp,"_", p[iARG.pp], "_",iARG.ax,"_", p[iARG.ax],"_tspan_", pert.tspan,"_saveat_", pert.saveat,"_pt_", t,".txt"), "w") do outfile1
            writedlm(outfile1, [vcat("Syst", "Time", [string(i) for i in mm.odeFB.syms])],'\t');
            syst = mm.odeFB
            solFB = fn.Dyn(syst, p, x0, pert.tspan, 1e-12, pert.saveat, [], fn.PertCallback(pert.p, pert.d, t, mm), pert.maxiters, true);
            syst = mm.odeNF
            solNF = fn.Dyn(syst, p, x0, pert.tspan, 1e-12, pert.saveat, [], fn.PertCallback(pert.p, pert.d, t, mm), pert.maxiters, true);
            if fn.CheckSync(solFBR, solFB, solNF, t, mm)
                writedlm(outfile1, [vcat(NaN, NaN, zeros(length(mm.odeFB.states.value)).+NaN)], '\t');
            else
                writedlm(outfile1, hcat(vcat(fill("FBR", length(solFBR)), fill("FB", length(solFB)), fill("NF", length(solNF))),vcat(solFBR.t,solFB.t,solNF.t),vcat(map(x->x',vcat(solFBR.u,solFB.u,solNF.u))...)), '\t');
            end
        end 
    end
# Function to obtain multiple dynamics of a system under different conditions/environments when perturbed  - uses callbacks
elseif(iARG.an == "ExMultiDynOsc")
    open(string("OutputFiles/OUT_", iARG.an,"_", iARG.mm,"_", iARG.ex,"_", iARG.pp,"_",iARG.ax,"_", pert.r[1],"-",pert.r[2],"_tspan_", pert.tspan,"_saveat_", pert.saveat,"_pt_", pert.pt,".txt"), "w") do outfile1
        writedlm(outfile1, [vcat(pert.c, "Syst", "Time", [string(i) for i in mm.odeFB.syms])],'\t');
        # Simulations before perturbation
        r = collect(pert.r[1]:pert.s:pert.r[2]);
        #r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        #r = range(pert.r[1], pert.r[2], length = pert.s);
        #r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
        for i in 1:length(r)
            p[pert.c] = r[i];
            syst = mm.odeFB
            x0 .= fn.x0(syst, x0, p)
            global solFBR = fn.Dyn(syst, p, x0, pert.tspan, 1e-12, pert.saveat, pert.pt, nothing, pert.maxiters, true);
            @eval mm solFBR = Main.solFBR
            solFB = fn.Dyn(syst, p, x0, pert.tspan, 1e-12, pert.saveat, [], fn.PertCallback(pert.p, pert.d, pert.pt, mm), pert.maxiters, true);
            syst = mm.odeNF
            solNF = fn.Dyn(syst, p, x0, pert.tspan, 1e-12, pert.saveat, [], fn.PertCallback(pert.p, pert.d, pert.pt, mm), pert.maxiters, true);
            if fn.CheckSync(solFBR, solFB, solNF, pert.pt, mm)
                writedlm(outfile1, [vcat(r[i], NaN, NaN, zeros(length(mm.odeFB.states.value)).+NaN)], '\t');
            else
                writedlm(outfile1, hcat(fill(r[i], length(solFBR)+length(solFB)+length(solNF)), vcat(fill("FBR", length(solFBR)), fill("FB", length(solFB)), fill("NF", length(solNF))),vcat(solFBR.t,solFB.t,solNF.t),vcat(map(x->x',vcat(solFBR.u,solFB.u,solNF.u))...)), '\t');
            end
        end
    end
# Function to obtain the dynamics of a system in response to a perturbation applied at different times (pt) - does not use callbacks
elseif(iARG.an == "ExDynOsc2")
    syst = mm.odeFB
    x0 .= fn.x0(syst, x0, p)
    global solFBR1 = fn.Dyn(syst, p, x0, pert.pt[end], 1e-8, [], pert.pt, nothing, Int(1e6), true);
    @eval mm solFBR = Main.solFBR1
    solFB1 = fn.Dyn(syst, p, x0, pert.pt[end], 1e-8, [], pert.pt, nothing, Int(1e6), true);
    syst = mm.odeNF
    solNF1 = fn.Dyn(syst, p, x0, pert.pt[end], 1e-8, [], pert.pt, nothing, Int(1e6), true);
    syncFlag = fn.CheckSync(solFBR1, solFB1, solNF1, pert.pt[end], mm)
    if !syncFlag
        for t in pert.pt
            open(string("OutputFiles/OUT_", iARG.an,"_", iARG.mm,"_", iARG.ex,"_", iARG.pp,"_", p[iARG.pp], "_",iARG.ax,"_", p[iARG.ax],"_tspan_", pert.tspan,"_saveat_", pert.saveat,"_pt_", t,".txt"), "w") do outfile1
                writedlm(outfile1, [vcat("Syst", "Time", [string(i) for i in mm.odeFB.syms])],'\t');
                i, j, k = findfirst(solFBR1.t .== t), findfirst(solFB1.t .== t),findfirst(solNF1.t .== t)
                writedlm(outfile1, hcat(vcat(fill("FBR", length(solFBR1[1:i])), fill("FB", length(solFB1[1:j])), fill("NF", length(solNF1[1:k]))),vcat(solFBR1[1:i].t,solFB1.t[1:j],solNF1[1:k].t),vcat(map(x->x',vcat(solFBR1[1:i].u,solFB1[1:j].u,solNF1[1:k].u))...)), '\t');
                x0 = solFBR1[i]
                syst = mm.odeFB
                global solFBR2 = fn.Dyn(syst, p, x0, pert.tspan - pert.pt, 1e-8, pert.saveat, [], nothing, pert.maxiters, true);
                @eval mm solFBR = Main.solFBR2
                p[pert.p] *= pert.d;
                solFB2 = fn.Dyn(syst, p, x0, pert.tspan - pert.pt, 1e-8, pert.saveat, [], nothing, pert.maxiters, true);
                syst = mm.odeNF
                solNF2 = fn.Dyn(syst, p, x0, pert.tspan - pert.pt, 1e-8, pert.saveat, [], nothing, pert.maxiters, true);
                writedlm(outfile1, hcat(vcat(fill("FBR", length(solFBR2)), fill("FB", length(solFB2)), fill("NF", length(solNF2))),vcat(solFBR2.t .+ solFBR1.t[end],solFB2.t .+ solFB1.t[end],solNF2.t .+ solNF1.t[end]),vcat(map(x->x',vcat(solFBR2.u,solFB2.u,solNF2.u))...)), '\t');
                p[pert.p] /= pert.d;
            end
        end
    end
# Function to obtain multiple dynamics of a system under different conditions/environments when perturbed  - does not use callbacks
elseif(iARG.an == "ExMultiDynOsc2")
    open(string("OutputFiles/OUT_", iARG.an,"_", iARG.mm,"_", iARG.ex,"_", iARG.pp,"_",iARG.ax,"_", pert.r[1],"-",pert.r[2],"_tspan_", pert.tspan,"_saveat_", pert.saveat,"_pt_", pert.pt,".txt"), "w") do outfile1
        writedlm(outfile1, [vcat(pert.c, "Syst", "Time", [string(i) for i in mm.odeFB.syms])],'\t');
        # Simulations before perturbation
        # r = collect(pert.r[1]:pert.s:pert.r[2]);
        #r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        r = range(pert.r[1], pert.r[2], length = pert.s);
        #r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
        for i in 1:length(r)
            print(r[i])
            p[pert.c] = r[i];
            syst = mm.odeFB
            x0 .= fn.x0(syst, x0, p)
            global solFBR = fn.Dyn(syst, p, x0, pert.pt, 1e-8, [], pert.pt, nothing, Int(1e6), true);
            @eval mm solFBR = Main.solFBR
            solFB = fn.Dyn(syst, p, x0, pert.pt, 1e-8, [], pert.pt, nothing, Int(1e6), true);
            syst = mm.odeNF
            solNF = fn.Dyn(syst, p, x0, pert.pt, 1e-8, [], pert.pt, nothing, Int(1e6), true);
            writedlm(outfile1, hcat(fill(r[i], length(solFBR)+length(solFB)+length(solNF)),vcat(fill("FBR", length(solFBR)), fill("FB", length(solFB)), fill("NF", length(solNF))),vcat(solFBR.t,solFB.t,solNF.t),vcat(map(x->x',vcat(solFBR.u,solFB.u,solNF.u))...)), '\t');
            syncFlag = fn.CheckSync(solFBR, solFB, solNF, pert.pt, mm)
            if !syncFlag
                x0 .= solFBR[end]
                syst = mm.odeFB
                global solFBR = fn.Dyn(syst, p, x0, pert.tspan - pert.pt, 1e-8, pert.saveat, [], nothing, pert.maxiters, true);
                @eval mm solFBR = Main.solFBR
                p[pert.p] *= pert.d;
                solFB = fn.Dyn(syst, p, x0, pert.tspan - pert.pt, 1e-8, pert.saveat, [], nothing, pert.maxiters, true);
                syst = mm.odeNF
                solNF = fn.Dyn(syst, p, x0, pert.tspan - pert.pt, 1e-8, pert.saveat, [], nothing, pert.maxiters, true);
                writedlm(outfile1, hcat(fill(r[i], length(solFBR)+length(solFB)+length(solNF)),vcat(fill("FBR", length(solFBR)), fill("FB", length(solFB)), fill("NF", length(solNF))),vcat(solFBR.t .+ pert.pt,solFB.t .+ pert.pt,solNF.t .+ pert.pt),vcat(map(x->x',vcat(solFBR.u,solFB.u,solNF.u))...)), '\t');
                p[pert.p] /= pert.d;
            end
        end
    end
# Function to calculate CoRaDyn under different conditions/environments
elseif(iARG.an == "ExCoRaDyn")
    for tspan in pert.tspan
        open(string("OutputFiles/OUT_", iARG.an,"_", iARG.mm,"_", iARG.ex,"_", iARG.pp,"_",iARG.ax,"_", pert.r[1],"-",pert.r[2],"_tspan_", tspan,"_saveat_", pert.saveat,"_pt_", pert.pt,".txt"), "w") do outfile1
            writedlm(outfile1, [vcat(iARG.ax, string("CoRaDyn(",iARG.pp,")"), "FBflag", "NFflag", "FBarea", "NFarea")],'\t');
            # Simulations before perturbation
            # r = collect(pert.r[1]:pert.s:pert.r[2]);
            #r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
            r = range(pert.r[1], pert.r[2], length = pert.s);
            #r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
            for i in 1:length(r)
                p[pert.c] = r[i];
                syncFlag, x0s = fn.x0andCheckSync(mm, x0, p, pert.pt);
                if !syncFlag
                    x0 .= x0s[1]
                    syst = mm.odeFB
                    global solFBR = fn.Dyn(syst, p, x0, tspan - pert.pt + 1e4, 1e-12, pert.saveat, tspan - pert.pt, nothing, pert.maxiters, true);
                    @eval mm solFBR = Main.solFBR
                    p[pert.p] *= pert.d;
                    solFB = fn.Dyn(syst, p, x0, tspan - pert.pt + 1e4, 1e-12, pert.saveat, tspan - pert.pt, nothing, pert.maxiters, true);
                    syst = mm.odeNF
                    solNF = fn.Dyn(syst, p, x0, tspan - pert.pt + 1e4, 1e-12, pert.saveat, tspan - pert.pt, nothing, pert.maxiters, true);
                    p[pert.p] /= pert.d;
                    CoRaDynOsc, FBflag, NFflag, FBarea, NFarea = fn.CoRaDynOsc(pert.pt, tspan, solFBR, solFB, solNF, mm)
                    writedlm(outfile1, [vcat(p[pert.c],CoRaDynOsc,FBflag,NFflag, FBarea, NFarea)], '\t');
                end
            end
        end
    end
# Function to calculate CoRaDyn of a system that was perturbed at different times
elseif(iARG.an == "ExPertTimeTest")
    for tspan in pert.tspan
        open(string("OutputFiles/OUT_", iARG.an,"_", iARG.mm,"_", iARG.ex,"_", iARG.pp,"_", p[iARG.pp], "_",iARG.ax,"_", p[iARG.ax],"_tspan_", tspan,"_saveat_", pert.saveat,"_pt_", pert.pt[1],"-", pert.pt[end],".txt"), "w") do outfile1
            writedlm(outfile1, [vcat("pt", string("CoRaDyn(",iARG.pp,")"), "FBflag", "NFflag", "FBarea", "NFarea")],'\t');
            # Simulations before perturbation
            syncFlag, x0s = fn.x0andCheckSync(mm, x0, p, pert.pt)
            if !syncFlag
                for i in 1:length(pert.pt)
                    t = pert.pt[i]
                    x0 = x0s[i]
                    syst = mm.odeFB
                    global solFBR = fn.Dyn(syst, p, x0, tspan - t + 1e4, 1e-12, pert.saveat, tspan - t, nothing, pert.maxiters, true);
                    @eval mm solFBR = Main.solFBR
                    p[pert.p] *= pert.d;
                    solFB = fn.Dyn(syst, p, x0, tspan - t + 1e4, 1e-12, pert.saveat, tspan - t, nothing, pert.maxiters, true);
                    syst = mm.odeNF
                    solNF = fn.Dyn(syst, p, x0, tspan - t + 1e4, 1e-12, pert.saveat, tspan - t, nothing, pert.maxiters, true);
                    p[pert.p] /= pert.d;
                    CoRaDynOsc, FBflag, NFflag, FBarea, NFarea = fn.CoRaDynOsc(t, tspan, solFBR, solFB, solNF, mm)
                    writedlm(outfile1, [vcat(t,CoRaDynOsc,FBflag,NFflag, FBarea, NFarea)], '\t');
                end
            end
        end
    end
end