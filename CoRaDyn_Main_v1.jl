#### CoRaDyn_v1

### Load functions & parameters
using DelimitedFiles
using Distributions

## Include the external library that defines all the analysis-related functions required by the main script 
fn = include(string("Library/FN_CoRaDyn.jl"));
## Include the model to be evaluated 
mm = include(string("Library/Md_",iARG.mm,".jl"));
## Include the parameters and perturbation details 
# iARG = (mm : Label for motif file, ex : Label for parameters file, pp : Label for perturbation type, an : Chose analysis type);
include(string("InputFiles/ARGS_",iARG.mm,"_Pert_",iARG.ex,".jl"))	
include(string("InputFiles/ARGS_",iARG.mm,"_Par_",iARG.ex,".jl"))

### Calculate CoRa across a range of conditions/environments 
if(iARG.an == "ExCoRa") 
    ## Create output file 
    open(string("OutputFiles/OUT_",iARG.an,"_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax,"_",pert.r[1],"-",pert.r[2],".txt"), "w") do outfile1
        ## Generate and write the header row for the output data file 
        writedlm(outfile1, [vcat(iARG.ax,[string("FbR_",i) for i in mm.odeFB.syms],[string("FbD_",i) for i in mm.odeFB.syms],[string("NfR_",i) for i in mm.odeNF.syms],[string("NfD_",i) for i in mm.odeNF.syms],string("CoRa(",iARG.pp,")"))],'\t');
        ## Define the range of conditions/environments over which the model will be evaluated 
        r = range(pert.r[1], pert.r[2], length = pert.s);
        for i in 1:length(r)
            ## Update the parameter value
            p[pert.c[1]] = r[i];
            ## Find the pre-perturbation steady state of both the feedback (ssR) and no-feedback system (soR)
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            ## Apply the perturbation and obtain the post-perturbation steady state of the feedback (ssD) and non-feedback system (soD)
            ssD, soD = fn.Perturbation(ssR, soR, p, rtol, mm, pert.p, pert.d)
            ## Compute CoRa 
            CoRa = fn.CoRa(mm.outFB(ssR), mm.outFB(ssD), mm.outNF(soR), mm.outNF(soD))
            ## Save computed analysis results into the output file
            writedlm(outfile1, [vcat(p[pert.c[1]],ssR,ssD,soR,soD,CoRa)],'\t');
        end
    end
### Calculate CoRaDyn across a range of parameters (e.g., conditions/environments)
elseif(iARG.an == "ExCoRaDyn")
    ## Create output file 
    open(string("OutputFiles/OUT_",iARG.an,"_",iARG.mm,"_",iARG.ex,"_",iARG.pp,"_",iARG.ax[1],"_",pert.r[1],"-",pert.r[2],".txt"), "w") do outfile1
        ## Generate and write the header row for the output data file 
        writedlm(outfile1, [vcat(iARG.ax, string("CoRaDyn(",iARG.pp,")"))],'\t');
        ## Define the range of conditions/environments over which the model will be evaluated 
        r = range(pert.r[1], pert.r[2], length = pert.s);
        ## Terminate process if the tspan vector contains more than one value
        if length(pert.tspan) != 1
            error("Invalid tspan. This analysis requires a single evaluation time (tspan). Check Pert file.")
        end
        tspan = pert.tspan[1]
        for i in 1:length(r)
            ## Update the value of the condition parameter 
            p[pert.c[1]] = r[i]; 
            ## Find the pre-perturbation steady state of both the feedback (ssR) and no-feedback system (soR)
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            ## Continue to the next condition if the pre-perturbation steady state is not found 
            if any(isnan, ssR) || any(isinf, ssR) || any(isnan, soR) || any(isinf, soR)
                println("Skipping parameter set, pre-perturbation steady states have not been found, do not match or contain Inf/-Inf: ", pert.c[1], " ", p[pert.c[1]])
                writedlm(outfile1, [vcat(p[pert.c[1]],NaN)],'\t');
                continue
            end
            ## Apply the perturbation
            p[pert.p] *= pert.d;
            ## Simulate the response of the feedback system following a step perturbation
            syst = mm.odeFB;
            yFB = fn.Dyn(syst, p, ssR, tspan + 1e4, rtol, pert.saveat, tspan);
            ## Simulate the response of the no-feedback system following a step perturbation 
            syst = mm.odeNF;
            yNF = fn.Dyn(syst, p, soR, tspan + 1e4, rtol, pert.saveat, tspan);
            ## Revert the perturbation
            p[pert.p] /= pert.d;
            ## Compute CoRaDyn
            CoRaDyn = fn.CoRaDyn(tspan, yFB, ssR, yNF, soR, mm)
            ## Save computed analysis results into the output file
            writedlm(outfile1, [vcat(p[pert.c[1]],CoRaDyn)],'\t');
        end
    end
### Calculate CoRaDyn across a range of evaluation time windows (tspan)
elseif(iARG.an == "ExCoRaDyn_tspan")
    ## Create output file 
    open(string("OutputFiles/OUT_",iARG.an,"_",iARG.mm,"_",iARG.ex,"_",iARG.pp, join([string("_", i, p[i]) for i in iARG.ax]),"_tspan",pert.tspan[1],"-",pert.tspan[2],".txt"), "w") do outfile1
        ## Generate and write the header row for the output data file 
        writedlm(outfile1, [vcat("tspan", string("CoRaDyn(",iARG.pp,")"))],'\t');
        ## Set the time intervals (tspan) over which the system response will be evaluated
        # If the user provides a specific time or time vector, use it directly 
        if length(pert.tspan) > 2 || length(pert.tspan) == 1
            tspan = pert.tspan
        # If minimum, maximum, and length are provided, generate a linear range 
        elseif pert.tlog == false
            tspan = range(pert.tspan[1], pert.tspan[2], length = pert.l);
        # If the tlog flag is true create the range with a log scale
        else 
            tspan = 10 .^ range(log10(pert.tspan[1]), log10(pert.tspan[2]), length = pert.l);
        end
        ## Find the pre-perturbation steady state of both the feedback (ssR) and no-feedback system (soR)
        ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
        ## Apply the perturbation
        p[pert.p] *= pert.d;
        ## Simulate the response of the feedback system following a step perturbation 
        syst = mm.odeFB;
        yFB = fn.Dyn(syst, p, ssR, maximum(tspan) .+ 1e4, rtol, saveat, tspan);
        ## Simulate the response of the no-feedback system following a step perturbation
        syst = mm.odeNF;
        yNF = fn.Dyn(syst, p, soR, maximum(tspan) .+ 1e4, rtol, saveat, tspan);
        ## Revert the perturbation
        p[pert.p] /= pert.d;
        ## Compute CoRaDyn for each time interval (tspan)
        for t in tspan
            print("CoRaDyn", " ", t, "\n")
            CoRaDyn = fn.CoRaDyn(t, yFB, ssR, yNF, soR, mm)
            ## Save computed analysis results into the output file
            writedlm(outfile1, [vcat(t,CoRaDyn)],'\t');
        end
    end
### Calculate CoRaDyn while varying multiple parameters and/or evaluation time windows (tspan)
elseif(iARG.an == "ExMultiCoRaDyn")
    ## Create output file 
    open(string("OutputFiles/OUT_",iARG.an,"_",iARG.mm,join(["_" * string(i) for i in iARG.ax], ""),"_",iARG.pp,"_tspan",join(["-" * string(i) for i in pert.tspan], ""),".txt"), "w") do outfile1
        ## Generate and write the header row for the output data file
        writedlm(outfile1, [vcat("tspan", iARG.ax, string("CoRaDyn(",iARG.pp,")"))],'\t');
        ## Set the time intervals (tspan) over which the system response will be evaluated
        # If the user provides a specific time or time vector, use it directly 
        if length(pert.tspan) > 2 || length(pert.tspan) == 1
            tspan = pert.tspan
        # If minimum, maximum, and length are provided, generate a linear range 
        elseif pert.tlog == false
            tspan = range(pert.tspan[1], pert.tspan[2], length = pert.l);
        # If the tlog flag is true create the range with a log scale
        else 
            tspan = 10 .^ range(log10(pert.tspan[1]), log10(pert.tspan[2]), length = pert.l);
        end
        ## Define the parameter and tspan combinations (if applicable) over which the model will be evaluated 
        r = [range(a[1], a[2], length=n) for (a, n) in zip(pert.r, pert.s)]
        for values in Iterators.product(r...)
            ## Assign each value to the corresponding parameter
            for (key, val) in zip(pert.c, values)
                p[key] = val
            end
            ## Find the pre-perturbation steady state of both the feedback (ssR) and no-feedback system (soR)
            ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
            ## Continue to the next conditions if the pre-perturbation steady state is not found 
            if any(isnan, ssR) || any(isinf, ssR) || any(isnan, soR) || any(isinf, soR)
                println("Skipping parameter set, pre-perturbation steady states have not been found, do not match or contain Inf/-Inf: ", values)
                # CoRaDyn is NaN for this parameter combination
                if length(pert.tspan) == 1
                    writedlm(outfile1, [vcat(tspan,[i for i in values],NaN)],'\t');
                # CoRaDyn is NaN for this parameter combination accross all evaluated tspan values 
                else 
                    writedlm(outfile1, hcat(reshape(tspan, :, 1), repeat(reshape(collect(values), 1, :), length(tspan), 1), fill(NaN, length(tspan), 1)), '\t')
                end 
                continue
            end
            ## Apply the perturbation
            p[pert.p] *= pert.d;
            ## Simulate the response of the feedback system following a step perturbation 
            syst = mm.odeFB;
            yFB = fn.Dyn(syst, p, ssR, maximum(tspan) + 1e4, rtol, pert.saveat, tspan);
            ## Simulate the response of the no-feedback system following a step perturbation
            syst = mm.odeNF;
		    yNF = fn.Dyn(syst, p, soR, maximum(tspan) + 1e4, rtol, pert.saveat, tspan);
            ## Compute CoRaDyn for each time interval (tspan)
            for t in tspan 
                print("\n", t, " ", values, "\n")
                CoRaDyn = fn.CoRaDyn(t, yFB, ssR, yNF, soR, mm)
                ## Save computed analysis results into the output file
                writedlm(outfile1, [vcat(t,[i for i in values],CoRaDyn)],'\t');
            end
            ## Revert the perturbation
            p[pert.p] /= pert.d;
            ## Set yFB and yNF to `nothing` to release their references. 
            # This allows the memory used by the ODE solutions to be reclaimed by the garbage collector.
            yFB = nothing
		    yNF = nothing 
        end
    end
### Obtain system dynamics under specific conditions
elseif(iARG.an == "ExDyn")
    ## Create output file 
    open(string("OutputFiles/OUT_",iARG.an,"_", iARG.mm, "_", iARG.ex, "_", iARG.pp, join([string("_", i, p[i]) for i in iARG.ax]), ".txt"), "w") do outfile1
        ## Generate and write the header row for the output data file
        writedlm(outfile1, [vcat("FB","rho","time",[string(i) for i in mm.odeNF.syms])], '\t');
        ## Find the pre-perturbation steady state of both the feedback (ssR) and no-feedback system (soR)
        ssR, soR, rtol = fn.SSandCheck(p, x0, 1e-12, mm, pert.p)
        ## Simulate the dynamics of the feedback system before applying the step perturbation
        syst = mm.odeFB;
        x = fn.Dyn(syst, p, ssR, 500.0, rtol, pert.saveat, []);
        ## If an error occurs, save the dynamics as NaN
        try
            if(any(isnan.(x)))
                writedlm(outfile1, [vcat(1,p[iARG.pp],0,x,"NaN")],'\t');
            end
        catch
            for i in 1:length(x.t)
                writedlm(outfile1, [vcat(1,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
            end
            ## Apply the perturbation
            p[pert.p] *= pert.d;
            ## Simulate the response of the feedback system following a step perturbation 
            x = fn.Dyn(syst, p, ssR, pert.tspan, rtol, pert.saveat, [])
            ## If an error occurs, save the dynamics as NaN
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(1,p[iARG.pp],pert.tspan,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(1,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                end
                ## Revert the perturbation
		        p[pert.p] /= pert.d;
            end
        end
        ## Simulate the dynamics of the no-feedback system before applying the step perturbation
        syst = mm.odeNF;
        x = fn.Dyn(syst, p, soR, 500.0, rtol, pert.saveat, [])
        ## If an error occurs, save the dynamics as NaN
        try
            if(any(isnan.(x)))
                writedlm(outfile1, [vcat(0,p[iARG.pp],0,x,"NaN")],'\t');
            end
        catch
            for i in 1:length(x.t)
                writedlm(outfile1, [vcat(0,p[iARG.pp],x.t[i],x.u[i],"NaN")],'\t');
            end
            ## Apply the perturbation
            p[pert.p] *= pert.d;
            ## Simulate the response of the feedback system following a step perturbation 
            x = fn.Dyn(syst, p, soR, pert.tspan, rtol, pert.saveat, [])
            ## If an error occurs, save the dynamics as NaN
            try
                if(any(isnan.(x)))
                    writedlm(outfile1, [vcat(0,p[iARG.pp],pert.tspan,x,"NaN")],'\t');
                end
            catch
                for i in 1:length(x.t)
                    writedlm(outfile1, [vcat(0,p[iARG.pp],x.t[i]+500.0,x.u[i],"NaN")],'\t');
                end
                ## Revert the perturbation
		        p[pert.p] /= pert.d;
            end
        end
    end
end
