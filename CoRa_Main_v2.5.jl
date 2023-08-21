###CoRa_v2.5

###Alright, once and for all
###In the spirit of proper documentation, I'll be as explicit as I can with these comments
###Taken from v2, no need to modify this just yet
## Load functions & parameters:
using DelimitedFiles
using Distributions

#This includes the model to study itself, it must be prepared before running CoRa, with the explicit constraint that the number of d/dt are the same in the FB and NF equations
mm = include(string("Library/Md_",iARG.mm,".jl"));
###This next line is changed to use the "updated" functions .jl
fn = include(string("Library/FN_CoRa.jl"));
## INPUTS:
# iARG = (mm : Label for motif file, ex : Label for parameters file, pp : Label for perturbation type, an : Chose analysis type);
include(string("InputFiles/ARGS_",iARG.mm,"_Pert_",iARG.ex,".jl"))	# Perturbation details
include(string("InputFiles/ARGS_",iARG.mm,"_Par_",iARG.ex,".jl"))	# Core parameters
p0 = copy(p);

if(iARG.an == "ExSSs")
    ###The tag was replaced from "io" to "outfile1" with the intention of creating a "report card" output file down the line, which would necessitate the existence of multiple output files
    open(string("OutputFiles/OUT_ExSSs_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.r[1],"-",pert.r[2],".txt"), "w") do outfile1
        ###This generates the headers for our data output, we're preparing the file beforehand
        writedlm(outfile1, [vcat(iARG.ax,[string("FbR_",i) for i in mm.odeFB.syms],[string("FbD_",i) for i in mm.odeFB.syms],[string("NfR_",i) for i in mm.odeNF.syms],[string("NfD_",i) for i in mm.odeNF.syms],string("CoRa(",iARG.pp,")"))],'\t');
        ###This creates our "steps" for the data production, as stated in the .*_Pert_.*.jl file
        # r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        # r = range(pert.r[1], pert.r[2], length = pert.s);
        r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
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
            ###With everything done, it's time to output them into the file!
            writedlm(outfile1, [vcat(p[pert.c],ssR,ssD,soR,soD,CoRa)],'\t');
        end
    end
elseif(iARG.an == "ExSSs_points")
    ###The tag was replaced from "io" to "outfile1" with the intention of creating a "report card" output file down the line, which would necessitate the existence of multiple output files
    open(string("OutputFiles/OUT_ExSSs_points_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.saveat[1],"-",last(pert.saveat),".txt"), "w") do outfile1
        ###This generates the headers for our data output, we're preparing the file beforehand
        writedlm(outfile1, [vcat("tspan",iARG.ax,"FbR","FbD","NfR","NfD",string("CoRa(",iARG.pp,")"))],'\t');
        ###Up next, we must find the steady states of both ssR and soR, while also checking that the process itself didn't fail. Let's make that a single, "fn.SSandCheck()" function
        ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
        p[pert.p] *= pert.d;
        # Feedback
        syst = mm.odeFB;
        yFB = fn.Dyn(syst, p, ssR, pert.tspan + 1e4, rtol, pert.saveat, []);
        # No feedback
        syst = mm.odeNF;
        yNF = fn.Dyn(syst, p, soR, pert.tspan + 1e4, rtol, pert.saveat, []);
        p[pert.p] /= pert.d;
        ###And we must return CoRa now, too
        CoRa = fn.CoRa(mm.outFB(ssR), mm.solFB(yFB), mm.outNF(soR), mm.solNF(yNF))
        ###With everything done, it's time to write the output to the file!
        lenSaveat = length(pert.saveat)
        writedlm(outfile1, hcat(collect(pert.saveat),repeat([p[pert.c]], lenSaveat),repeat([mm.outFB(ssR)],lenSaveat),mm.solFB(yFB),repeat([mm.outNF(soR)],lenSaveat),mm.solNF(yNF),CoRa),'\t');
    end
elseif(iARG.an == "PertTestCoRa")
    open(string("OutputFiles/OUT_", iARG.an, "_",iARG.mm,"_",iARG.ex,"_",iARG.pp,p[pert.p],"_",iARG.ax,p[pert.c],".txt"), "w") do outfile1
        writedlm(outfile1, [vcat("PertSize", string("CoRa(",iARG.pp,")"))],'\t');
        for d in pert.d
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            ssD, soD = fn.Perturbation(ssR, soR, p, rtol, mm, pert.p, d)
            CoRa = fn.CoRa(mm.outFB(ssR), mm.outFB(ssD), mm.outNF(soR), mm.outNF(soD))
            writedlm(outfile1, [vcat(d,CoRa)],'\t');
        end
    end
elseif(iARG.an == "ExSSs_Dyn")
    open(string("OutputFiles/OUT_ExSSs_Dyn_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.r[1],"-",pert.r[2],".txt"), "w") do outfile1
        writedlm(outfile1, [vcat(iARG.ax, string("CoRa(",iARG.pp,")"))],'\t');
        # r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        # r = range(pert.r[1], pert.r[2], length = pert.s);
        r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
        for i in 1:length(r)
            p[pert.c] = r[i];
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            syst = mm.odeFB;
            p[pert.p] *= pert.d;
            yFB = fn.Dyn(syst, p, ssR, pert.tspan + 1e4, rtol, pert.saveat, pert.tspan);
            syst = mm.odeNF;
            yNF = fn.Dyn(syst, p, soR, pert.tspan + 1e4, rtol, pert.saveat, pert.tspan);
            p[pert.p] /= pert.d;
            CoRaDyn = fn.CoRaDyn(pert.tspan, yFB, ssR, yNF, soR, mm)
            writedlm(outfile1, [vcat(p[pert.c],CoRaDyn)],'\t');
        end
    end
elseif(iARG.an == "ExSSs_Dyn_points")
    for saveat in [pert.saveat]
        open(string("OutputFiles/OUT_",iARG.an,"_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.tspan[1],"-",pert.tspan[end],"_saveat",saveat,".txt"), "w") do outfile1
            writedlm(outfile1, [vcat("tspan", string("CoRa(",iARG.pp,")"))],'\t');
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            p[pert.p] *= pert.d;
            syst = mm.odeFB;
            yFB = fn.Dyn(syst, p, ssR, 1e4, rtol, saveat, pert.tspan);
            syst = mm.odeNF;
            yNF = fn.Dyn(syst, p, soR, 1e4, rtol, saveat, pert.tspan);
            p[pert.p] /= pert.d;
            for t in pert.tspan
                print(saveat, " ", t, " ")
                CoRaDyn = fn.CoRaDyn(t, yFB, ssR, yNF, soR, mm)
                writedlm(outfile1, [vcat(t,CoRaDyn)],'\t');
            end
        end
    end
elseif(iARG.an == "PertTestCoRaDyn")
    open(string("OutputFiles/OUT_", iARG.an, "_", iARG.mm,"_",iARG.ex,"_",iARG.pp,p[pert.p],"_",iARG.ax,p[pert.c],"_tspan",pert.tspan,".txt"), "w") do outfile1
        writedlm(outfile1, [vcat("PertSize", string("CoRaDyn(",iARG.pp,")"))],'\t');
        for d in pert.d
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            syst = mm.odeFB;
            p[pert.p] *= d;
            yFB = fn.Dyn(syst, p, ssR, 1e6, rtol, [], pert.tspan);
            syst = mm.odeNF;
            yNF = fn.Dyn(syst, p, soR, 1e6, rtol, [], pert.tspan);
            p[pert.p] /= d;
            CoRaDyn = fn.CoRaDyn(pert.tspan, yFB, ssR, yNF, soR, mm)
            writedlm(outfile1, [vcat(d,CoRaDyn)],'\t');
        end
    end
elseif(iARG.an == "ExDyn")
    open(string("OutputFiles/OUT_ExDyn_", iARG.mm, "_", iARG.ex, "_", iARG.pp, "_", iARG.ax, ".txt"), "w") do outfile1
        writedlm(outfile1, [vcat("FB","rho","time",[string(i) for i in mm.odeNF.syms])], '\t');
        ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
        #This whole part is the feedback one
        syst = mm.odeFB;
        x = fn.Dyn(syst, p, ssR, 500.0, rtol, pert.saveat, 1);
        try
            if(any(isnan.(x)))
                writedlm(outfile1, [vcat(1,p[iARG.pp],0,x,"NaN")],'\t');
            end
        catch
            for i in 1:length(x.t)
                writedlm(outfile1, [vcat(1,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
            end
            p[pert.p] *= pert.d;
            x = fn.Dyn(syst, p, last(x.u), pert.tspan, rtol, pert.saveat, 1);
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(1,p[iARG.pp],500.0,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(1,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                end
                ssD = fn.SS(syst, p, ssR, rtol)
                writedlm(outfile1, [vcat(1,p[iARG.pp],"Inf",ssD,"NaN")],'\t');
		        p[pert.p] /= pert.d;
            end
        end
        #Now this whole thing is going to be the non-feedback one
        syst = mm.odeNF;
        x = fn.Dyn(syst, p, ssR, 500.0, rtol, pert.saveat, 1);
        try
            if(any(isnan.(x)))
                writedlm(outfile1, [vcat(0,p[iARG.pp],0,x,"NaN")],'\t');
            end
        catch
            for i in 1:length(x.t)
                writedlm(outfile1, [vcat(0,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
            end
            p[pert.p] *= pert.d;
            x = fn.Dyn(syst, p, last(x.u), pert.tspan, rtol, pert.saveat, 1);
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(0,p[iARG.pp],500.0,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(0,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                end
                ssD = fn.SS(syst, p, ssR, rtol)
                writedlm(outfile1, [vcat(0,p[iARG.pp],"Inf",ssD,"NaN")],'\t');
		        p[pert.p] /= pert.d;
            end
        end
        #Needs to be homogenized into the Functions-Based structure that CoRa now has, job for later rn it has to work :p
    end
elseif(iARG.an == "ExMultiDyn")
    open(string("OutputFiles/OUT_ExMultiDyn_", iARG.mm, "_", pert.r[1], "-", pert.r[2], "_", iARG.ex, "_", iARG.pp, "_", iARG.ax, ".txt"), "w") do outfile1
        writedlm(outfile1, [vcat("$(iARG.pp)", "FB","rho","time",[string(i) for i in mm.odeNF.syms])], '\t');
        # r = 10 .^ collect(pert.r[1]:pert.s:pert.r[2]);
        # r = 10 .^ range(log10(pert.r[1]), log10(pert.r[2]), length = pert.s);
        r = range(pert.r[1], pert.r[2], length = pert.s);
        for j in 1:length(r)
            p[iARG.pp] = r[j]
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            #This whole part is the feedback one
            syst = mm.odeFB;
            x = fn.Dyn(syst, p, ssR, 500.0, rtol, pert.saveat, []);
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(r[j],1,p[iARG.pp],0,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(r[j],1,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
                end
                p[pert.p] *= pert.d;
                x = fn.Dyn(syst, p, last(x.u), pert.tspan, rtol, pert.saveat, []);
                try
                    if(any(isnan.(x)))
                        writedlm(outfile1, [vcat(r[j],1,p[iARG.pp],500.0,x,"NaN")],'\t');
                    end
                catch
                    for i in 1:length(x.t)
                        writedlm(outfile1, [vcat(r[j],1,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                    end
                    ssD = fn.SS(syst, p, ssR, rtol)
                    writedlm(outfile1, [vcat(r[j],1,p[iARG.pp],"Inf",ssD,"NaN")],'\t');
                    p[pert.p] /= pert.d;
                end
            end
            #Now this whole thing is going to be the non-feedback one
            syst = mm.odeNF;
            x = fn.Dyn(syst, p, ssR, 500.0, rtol, pert.saveat, []);
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(r[j],0,p[iARG.pp],0,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(r[j],0,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
                end
                p[pert.p] *= pert.d;
                x = fn.Dyn(syst, p, last(x.u), pert.tspan, rtol, pert.saveat, []);
                try
                    if(any(isnan.(x)))
                        writedlm(outfile1, [vcat(r[j],0,p[iARG.pp],500.0,x,"NaN")],'\t');
                    end
                catch
                    for i in 1:length(x.t)
                        writedlm(outfile1, [vcat(r[j],0,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                    end
                    ssD = fn.SS(syst, p, ssR, rtol)
                    writedlm(outfile1, [vcat(r[j],0,p[iARG.pp],"Inf",ssD,"NaN")],'\t');
                    p[pert.p] /= pert.d;
                end
            end
        end
        #Needs to be homogenized into the Functions-Based structure that CoRa now has, job for later rn it has to work :p
    end
end
