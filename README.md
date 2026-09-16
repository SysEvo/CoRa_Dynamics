# CoRaDyn

CoRaDyn is a computational framework, built on CoRa (Gómez-Schiavon & El-Samad, 2022), that quantifies the contribution of feedback to a system's response as it unfolds over time, rather than only at steady state. It uses a mathematically controlled comparison against an identical system lacking the feedback. Like CoRa, CoRaDyn provides a simple, intuitive metric with broad applicability to biological feedback systems.

> This version is associated with the manuscript:
> Tamayo-Luisce A & Gómez-Schiavon M (2026). *Beyond Steady-State Adaptation: Evaluating the Dynamic Performance of Biological Feedback Control*. Preprint.

## Table of Contents

- [Installation](#installation)
- [Setting Up Input Files](#setting-up-input-files)
- [Analysis Types](#analysis-types)
- [Running an Analysis](#running-an-analysis)
- [Model (Md) File Structure](#model-md-file-structure)
- [Model Parameters File Structure](#model-parameters-file-structure)
- [Analysis Parameters File Structure](#analysis-parameters-file-structure)
- [Analysis Settings](#analysis-settings)
  - [`ExCoRa`](#excora)
  - [`ExCoRaDyn`](#excoradyn)
  - [`ExCoRaDyn_tspan`](#excoradyn_tspan)
  - [`ExMultiCoRaDyn`](#exmulticoradyn)
  - [`ExMultiPertCoRaDyn`](#exmultipertcoradyn)
  - [`ExDyn`](#exdyn)
  - [`ExMultiDyn`](#exmultidyn)
  - [`ExMultiPertDyn`](#exmultipertdyn)
- [References](#references)
- [Contact / Support](#contact--support)

## Installation

Julia is required. The code was last confirmed stable on Julia 1.8.5.

```bash
# Install Julia
curl -fsSL https://install.julialang.org | sh

# Install version 1.8.5
juliaup add 1.8.5

# Set 1.8.5 as the default version
juliaup default 1.8.5
```

## Setting Up Input Files

Before running an analysis, you need to create the following files:

- **Model file** — defines the model and lives in the `Library` directory, named `Md_[ModelName].jl`.
- **Model parameters file** — lives in the `InputFiles` directory, named `ARGS_[ModelName]_Par_[Label].jl` (e.g., `Ex01`).
- **Analysis parameters file** — also lives in the `InputFiles` directory, named `ARGS_[ModelName]_Pert_[Label].jl`.

The parameters required and their format depend on the specific analysis type; see [Analysis Settings](#analysis-settings) below.

After an analysis runs, its output is saved to the `OutputFiles` directory. If it doesn't already exist at the repository root, create an empty `OutputFiles` directory before running an analysis.

The `InputFiles` and `Library` files used for Tamayo-Luisce & Gómez-Schiavon (2026) are provided in subfolders named `ManuscriptInputFiles` and `ManuscriptLibrary`. For the code to run, move their contents into the corresponding parent directory (i.e., `InputFiles` or `Library`).

## Analysis Types

| Analysis | Description |
|---|---|
| `ExCoRa` | Calculate CoRa across a range of conditions/environments |
| `ExCoRaDyn` | Calculate CoRaDyn across a range of parameters (e.g., conditions/environments) |
| `ExCoRaDyn_tspan` | Calculate CoRaDyn across a range of evaluation time windows (`tspan`) |
| `ExMultiCoRaDyn` | Calculate CoRaDyn while varying multiple parameters and/or the evaluation time window (`tspan`) |
| `ExMultiPertCoRaDyn` | Calculate CoRaDyn across a range of perturbation sizes |
| `ExDyn` | Obtain system dynamics under specific conditions |
| `ExMultiDyn` | Obtain system dynamics under specific conditions while varying a parameter |
| `ExMultiPertDyn` | Obtain system dynamics under specific conditions while varying the perturbation size |

## Running an Analysis

1. In `Run_CoRaDyn.jl`, update the path to the root of your CoRaDyn repository (e.g., `/Users/username/Desktop/CoRaDyn/`).

2. Update `Run_CoRaDyn.jl` with the necessary execution parameters:

   ```julia
   mm = :NameOfModel,     # Same name used in the Md, Par, and Pert files
   ex = "Label",          # Same label used in the Par and Pert files (e.g. "Ex01")
   pp = :NameParam,       # Parameter on which the perturbation will be applied
   ax = [:NameParam],     # Parameter(s) to be varied (e.g. condition/environment)
   an = "AnalysisType"    # Name of the analysis type (see Analysis Types above)
   ```

3. Start Julia from the terminal, in the root of your CoRaDyn repository.

4. If this is your first time running one of these analyses, run the following commands once:

   ```julia
   import Pkg; Pkg.add("BenchmarkTools")
   Pkg.instantiate()
   ```

   If needed, install the following package separately:

   ```julia
   import Pkg; Pkg.add("JuliaFormatter")
   ```

5. In the terminal, run Julia and then:

   ```julia
   include("./Run_CoRaDyn.jl")
   ```

## Model (Md) File Structure

This file defines the model itself and is not changed between runs — only the model and analysis parameters (below) vary by analysis.

```julia
# ODE system (with feedback)
odeFB = @ode_def begin
    dVar1 = equation1   # terms with species and parameters; variable names omit the leading "d"
    dVar2 = equation2
end Par1 Par2 ...ListOfParameters

# ODE system without feedback
odeNF = @ode_def begin
    dVar1 = equation1
    dVar2 = equation2
end Par1 Par2 NameOfConstantInputForLocalAnalogousSystem ...ListOfParameters

# Define the system's output (the controlled variable):
function outFB(steady_state)
    return steady_state[idx_ctrl]   # idx_ctrl = position of the controlled variable in the model equations
end;
function outNF(steady_state)
    return steady_state[idx_ctrl]   # same idx_ctrl as above
end;

# Get the time series for the controlled variable:
function solFB(dynamics)
    return dynamics[idx_ctrl, :]   # same idx_ctrl as above
end;
function solNF(dynamics)
    return dynamics[idx_ctrl, :]   # same idx_ctrl as above
end;

# Define the locally analogous system:
function localNF(p, steady_state)
    p[:NameOfConstantInputForLocalAnalogousSystem] = respective_param * steady_state[idx_ctrl]
    # Modify as needed — may involve multiple parameters or none,
    # depending on how the constant input is defined in the model.
end;
```

See worked examples in `Library/ManuscriptLibrary`.

## Model Parameters File Structure

```julia
# Kinetic parameters
p = Dict([
    :NameOfParam1 => value1,
    :NameOfParam2 => value2,
    ...
    :NameOfConstantInputForLocalAnalogousSystem => NaN,
]);

# Initial conditions
x0 = ones(length(mm.odeFB.syms));
```

See worked examples in `InputFiles/ManuscriptInputFiles`.

## Analysis Parameters File Structure

```julia
# Perturbation details
pert = (p      = iARG.pp,      # Parameter to be perturbed. DO NOT EDIT.
        d      = 1.05,         # Perturbation size (Delta rho)
        c      = iARG.ax,      # Parameter(s) to be varied (e.g. condition/environment). DO NOT EDIT.
        r      = [r_min, r_max],   # Value range for each parameter to be varied
        s      = r_length,         # Length of the parameter range(s)
        tspan  = t_eval,           # Evaluation time(s): a single time point, a time vector, or a [min, max] range
        l      = t_length,         # Length of the time range (if applicable)
        tlog   = false,             # Set to true to generate the time range on a log scale
        saveat = []);               # Specific time points at which system dynamics should be saved
```

See worked examples in `InputFiles/ManuscriptInputFiles`.

## Analysis Settings

Below is the expected output and required parameter settings for each analysis type.

### `ExCoRa`

Outputs the CoRa values for a given model across a range of parameters reflecting conditions or environments.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [:NameParamToVary],     # Parameter to be varied (e.g. condition/environment)
an = "ExCoRa"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = 1.05,
c      = iARG.ax,
r      = [r_min, r_max],   # Range of the varied parameter
s      = r_length,         # Length of the parameter range
tspan  = NaN,               # Not used for this analysis
l      = NaN,               # Not used for this analysis
tlog   = false,
saveat = []
```

### `ExCoRaDyn`

Outputs the CoRaDyn values for a given model across a range of parameters reflecting conditions or environments.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [:NameParamToVary],     # Parameter to be varied (e.g. condition/environment)
an = "ExCoRaDyn"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = 1.05,
c      = iARG.ax,
r      = [r_min, r_max],   # Range of the varied parameter
s      = r_length,         # Length of the parameter range
tspan  = t_window,          # Evaluation time window (must be greater than 0)
l      = NaN,               # Only one evaluation time is specified above
tlog   = false,
saveat = []
```

### `ExCoRaDyn_tspan`

Outputs the CoRaDyn values for a given model and a single, static set of parameters/conditions across a range of evaluation time windows.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [],                     # No parameter is varied
an = "ExCoRaDyn_tspan"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = 1.05,
c      = iARG.ax,
r      = [NaN, NaN],       # No parameter is varied
s      = NaN,               # No parameter is varied
tspan  = [t_min, t_max],    # Range of evaluation time windows along the model's dynamics over which to calculate CoRaDyn
l      = t_length,          # Length of the vector
tlog   = false,              # Set to true to generate the time range on a log scale
saveat = []
```

### `ExMultiCoRaDyn`

Outputs the CoRaDyn values for a given model across a range of parameters reflecting conditions or environments, as well as multiple evaluation time windows. Unlike `ExCoRaDyn`, this analysis can vary more than one parameter.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,             # Same name used in the Md, Par, and Pert files
ex = "Label",                   # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,       # Parameter on which the perturbation will be applied
ax = [:Var1, :Var2, :VarX],     # Parameters to be varied (e.g. conditions/environments)
an = "ExMultiCoRaDyn"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = 1.05,
c      = iARG.ax,
r      = [[r1_min, r1_max], [r2_min, r2_max], [rn_min, rn_max]],  # Range of values for each varied parameter
s      = [r1_length, r2_length, rn_length],                        # Length of the range for each varied parameter
tspan  = [t_min, t_max],                                            # Range of evaluation time windows along the model's dynamics over which to calculate CoRaDyn
l      = t_length,                                                  # Length of the vector
tlog   = false,                                                      # Set to true to generate the time range on a log scale
saveat = []
```

### `ExMultiPertCoRaDyn`

Outputs the CoRaDyn values for a given model across a range of a single parameter, under different perturbation sizes.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [:NameParamToVary],     # Parameter to be varied (e.g. condition/environment)
an = "ExMultiPertCoRaDyn"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = [d1, d2, d3, d4, dn],   # List of perturbation sizes to test
c      = iARG.ax,
r      = [[r_min, r_max]],       # Range of the varied parameter (double bracket is intentional)
s      = r_length,               # Length of the parameter range
tspan  = t_window,                # Evaluation time window (must be greater than 0)
l      = NaN,                     # Only one evaluation time is specified above
tlog   = false,
saveat = []
```

### `ExDyn`

Outputs the dynamics of the model variables in response to a perturbation, from which the dynamics of the controlled variable are typically plotted.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [],                     # No parameter is varied
an = "ExDyn"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = 1.05,
c      = iARG.ax,
r      = [NaN, NaN],   # No parameter is varied
s      = NaN,          # No parameter is varied
tspan  = t_end,         # Time up to which the dynamics should be saved
l      = NaN,           # Only one evaluation time is specified above
tlog   = false,
saveat = []
```

### `ExMultiDyn`

Outputs the dynamics of the model variables in response to a perturbation, across different values of a single varied parameter, from which the dynamics of the controlled variable are typically plotted.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [:ParamToBeVaried],     # Parameter to be varied (e.g. condition/environment)
an = "ExMultiDyn"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = 1.05,
c      = iARG.ax,
r      = [r_min, r_max],   # Range of the varied parameter
s      = r_length,         # Length of the parameter range
tspan  = t_end,             # Time up to which the dynamics should be saved
l      = NaN,               # Only one evaluation time is specified above
tlog   = false,
saveat = []
```

### `ExMultiPertDyn`

Outputs the dynamics of the model variables in response to a perturbation, across different perturbation sizes, from which the dynamics of the controlled variable are typically plotted.

**In `Run_CoRaDyn.jl`:**

```julia
mm = :NameOfModel,          # Same name used in the Md, Par, and Pert files
ex = "Label",                # Same label used in the Par and Pert files (e.g. "Ex01")
pp = :NameParamToPerturb,    # Parameter on which the perturbation will be applied
ax = [],                     # No parameter is varied
an = "ExMultiPertDyn"
```

**In the analysis parameters file:**

```julia
p      = iARG.pp,
d      = [d1, d2, d3, d4, dn],   # List of perturbation sizes to test
c      = iARG.ax,
r      = [NaN, NaN],             # No parameter is varied
s      = NaN,                    # No parameter is varied
tspan  = t_end,                   # Time up to which the dynamics should be saved
l      = NaN,                     # Only one evaluation time is specified above
tlog   = false,
saveat = []
```

## References

Gómez-Schiavon, Mariana, and Hana El-Samad. 2022. "CoRa—A General Approach for Quantifying Biological Feedback Control." *Proceedings of the National Academy of Sciences* 119 (36): e2206825119. doi:[10.1073/pnas.2206825119](https://doi.org/10.1073/pnas.2206825119).

## Contact / Support

For questions or issues, contact Mariana Gómez-Schiavon at [MGSchiavon@liigh.unam.mx](mailto:MGSchiavon@liigh.unam.mx).
