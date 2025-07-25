###CoRaDyn_v1

###Alright, once and for all
###In the spirit of proper documentation, I'll be as explicit as I can with these comments
###Taken from v2, no need to modify this just yet
## Load functions & parameters:
using DelimitedFiles
using Distributions

#This includes the model to study itself, it must be prepared before running CoRa, with the explicit constraint that the number of d/dt are the same in the FB and NF equations
mm = include(string("Library/Md_",iARG.mm,".jl"));
###This next line is changed to use the "updated" functions .jl
fn = include(string("Library/FN_CoRaDyn.jl"));
## INPUTS:
# iARG = (mm : Label for motif file, ex : Label for parameters file, pp : Label for perturbation type, an : Chose analysis type);
include(string("InputFiles/ARGS_",iARG.mm,"_Pert_",iARG.ex,".jl"))	# Perturbation details
include(string("InputFiles/ARGS_",iARG.mm,"_Par_",iARG.ex,".jl"))	# Core parameters
p0 = copy(p);

# Calculate CoRa across a range of conditions/environments 
if(iARG.an == "ExSSs") 
    open(string("OutputFiles/OUT_ExSSs_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.r[1],"-",pert.r[2],".txt"), "w") do outfile1
        ###This generates the headers for our data output, we're preparing the file beforehand
        writedlm(outfile1, [vcat(iARG.ax,[string("FbR_",i) for i in mm.odeFB.syms],[string("FbD_",i) for i in mm.odeFB.syms],[string("NfR_",i) for i in mm.odeNF.syms],[string("NfD_",i) for i in mm.odeNF.syms],string("CoRa(",iARG.pp,")"))],'\t');
        ###This creates our "steps" for the data production, as stated in the .*_Pert_.*.jl file
        # r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        r = range(pert.r[1], pert.r[2], length = pert.s);
        # r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
        ###So, then, this will repeat the for loop in however many steps for the parameters
        for i in 1:length(r)
            ###The parameter to change is multiplied by the corresponding value in our steps collection, and the error tolerance is set to 1e-12 (arbitrarily)
            p[pert.c] = r[i];
            ###Up next, we must find the steady states of both ssR and soR, while also checking that the process itself didn't fail. Let's make that a single, "fn.SSandCheck()" function
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            ###Now, we have to do the Perturbation itself!
            ssD, soD = fn.Perturbation(ssR, soR, p, rtol, mm, pert.p, pert.d)
            ###And we must return CoRa now, too
            CoRa = fn.CoRa(mm.outFB(ssR), mm.outFB(ssD), mm.outNF(soR), mm.outNF(soD))
            print(CoRa)
            ###With everything done, it's time to output them into the file!
            writedlm(outfile1, [vcat(p[pert.c],ssR,ssD,soR,soD,CoRa)],'\t');
        end
    end
# Calculate CoRaDyn across a range of parameters (e.g., conditions/environments)
elseif(iARG.an == "ExSSs_Dyn")
    open(string("OutputFiles/OUT_ExSSs_Dyn_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.r[1],"-",pert.r[2],".txt"), "w") do outfile1
        writedlm(outfile1, [vcat(iARG.ax, string("CoRaDyn(",iARG.pp,")"))],'\t');
        # r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        r = range(pert.r[1], pert.r[2], length = pert.s);
        # r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
        for i in 1:length(r)
            p[pert.c] = r[i];
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            syst = mm.odeFB;
            p[pert.p] *= pert.d;
            yFB = fn.Dyn(syst, p, ssR, pert.tspan + 1e4, rtol, pert.saveat, pert.tspan .- pert.pt);
            syst = mm.odeNF;
            yNF = fn.Dyn(syst, p, soR, pert.tspan + 1e4, rtol, pert.saveat, pert.tspan .- pert.pt);
            p[pert.p] /= pert.d;
            CoRaDyn = fn.CoRaDyn(pert.tspan .- pert.pt, yFB, ssR, yNF, soR, mm)
            writedlm(outfile1, [vcat(p[pert.c],CoRaDyn)],'\t');
        end
    end
# Calculate CoRaDyn across a range of simulation time spans (tspan)
elseif(iARG.an == "ExSSs_Dyn_tspan")
    for saveat in [pert.saveat]
        open(string("OutputFiles/OUT_",iARG.an,"_",iARG.mm,"_",iARG.ex,"_",iARG.pp, join([string("_", i, p[i]) for i in iARG.ax]),"_tspan",pert.tspan[1],"-",pert.tspan[2],".txt"), "w") do outfile1
            writedlm(outfile1, [vcat("tspan", string("CoRaDyn(",iARG.pp,")"))],'\t');
            tspan = 10 .^ range(log10(pert.tspan[1]), log10(pert.tspan[2]), length = pert.l);
            #tspan = collect(pert.tspan) .- pert.pt
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            p[pert.p] *= pert.d;
            syst = mm.odeFB;
            yFB = fn.Dyn(syst, p, ssR, maximum(tspan) .+ 1e4, rtol, saveat, tspan);
            syst = mm.odeNF;
            yNF = fn.Dyn(syst, p, soR, maximum(tspan) .+ 1e4, rtol, saveat, tspan);
            p[pert.p] /= pert.d;
            for t in tspan
                print("CoRaDyn", " ", t, "\n")
                CoRaDyn = fn.CoRaDyn(t, yFB, ssR, yNF, soR, mm)
                writedlm(outfile1, [vcat(t,CoRaDyn)],'\t');
            end
        end
    end
# Calculate CoRaDyn across a range of multiple parameters (e.g., conditions or environments)
elseif(iARG.an == "ExMultiSSs_Dyn")
    open(string("OutputFiles/OUT_ExMultiSSs_Dyn_",iARG.mm,join(["_" * string(i) for i in iARG.ax], ""),"_bI", p[:bI], "_",iARG.pp,"_tspan",join(["-" * string(i) for i in pert.tspan], ""),".txt"), "w") do outfile1
        writedlm(outfile1, [vcat("tspan", iARG.ax, string("CoRaDyn(",iARG.pp,")"))],'\t');
        tspan = pert.tspan
        # tspan = range(pert.tspan[1], pert.tspan[2], length = pert.l);
        # tspan = (10 .^ range(log10(pert.tspan[1]), log10(pert.tspan[2]), length = pert.l) .- pert.pt);
        r = [range(a[1], a[2], length=n) for (a, n) in zip(pert.r, pert.s)]
        for values in Iterators.product(r...)
            # Assign each value to the corresponding parameter in `p`
            for (key, val) in zip(pert.c, values)
                p[key] = val
            end
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            if any(isnan, ssR) || any(isinf, ssR) || any(isnan, soR) || any(isinf, soR)
                println("Skipping parameter set, pre-perturbation SSs have not been found, do not match or contain Inf/-Inf: ", values)
                # Nota: Esto esta horrible. Mejor separa los análisis cuando se varía tspan o cuando se varía params.
                if (pert.l == 1) & (length(pert.tspan) <= 2)
                    writedlm(outfile1, [vcat(tspan,[i for i in values],NaN)],'\t');
                else 
                    writedlm(outfile1, hcat(reshape(tspan, :, 1), repeat(reshape(collect(values), 1, :), length(tspan), 1), fill(NaN, length(tspan), 1)), '\t')
                end 
                continue
            end
            p[pert.p] *= pert.d;
            yFB = fn.Dyn(mm.odeFB, p, ssR, maximum(tspan) + 1e4, rtol, pert.saveat, tspan);
		    yNF = fn.Dyn(mm.odeNF, p, soR, maximum(tspan) + 1e4, rtol, pert.saveat, tspan);
            for t in tspan 
                print("\n", t, " ", values, "\n")
                CoRaDyn = fn.CoRaDyn(t, yFB, ssR, yNF, soR, mm)
                writedlm(outfile1, [vcat(t,[i for i in values],CoRaDyn)],'\t');
            end 
            p[pert.p] /= pert.d;
            yFB = nothing
		    yNF = nothing 
        end
    end
# Obtain system dynamics under specific conditions
elseif(iARG.an == "ExDyn")
    open(string("OutputFiles/OUT_ExDyn_", iARG.mm, "_", iARG.ex, "_", iARG.pp, join([string("_", i, p[i]) for i in iARG.ax]), ".txt"), "w") do outfile1
        writedlm(outfile1, [vcat("FB","rho","time",[string(i) for i in mm.odeNF.syms])], '\t');
        ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
        #This whole part is the feedback one
        syst = mm.odeFB;
        x = fn.Dyn(syst, p, ssR, 500.0, rtol, pert.saveat, pert.tstops);
        try
            if(any(isnan.(x)))
                writedlm(outfile1, [vcat(1,p[iARG.pp],0,x,"NaN")],'\t');
            end
        catch
            for i in 1:length(x.t)
                writedlm(outfile1, [vcat(1,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
            end
            p[pert.p] *= pert.d;
            x = fn.Dyn(syst, p, ssR, pert.tspan, rtol, pert.saveat, pert.tstops)
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(1,p[iARG.pp],pert.tspan,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(1,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                end
		        p[pert.p] /= pert.d;
            end
        end
        #Now this whole thing is going to be the non-feedback one
        syst = mm.odeNF;
        x = fn.Dyn(syst, p, soR, 500.0, rtol, pert.saveat, pert.tstops)
        try
            if(any(isnan.(x)))
                writedlm(outfile1, [vcat(0,p[iARG.pp],0,x,"NaN")],'\t');
            end
        catch
            for i in 1:length(x.t)
                writedlm(outfile1, [vcat(0,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
            end
            p[pert.p] *= pert.d;
            x = fn.Dyn(syst, p, soR, pert.tspan, rtol, pert.saveat, pert.tstops)
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(0,p[iARG.pp],pert.tspan,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(0,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                end
		        p[pert.p] /= pert.d;
            end
        end
        #Needs to be homogenized into the Functions-Based structure that CoRa now has, job for later rn it has to work :p
    end
end
