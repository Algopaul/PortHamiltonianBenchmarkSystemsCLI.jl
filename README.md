# PortHamiltonianBenchmarkSystems CLI

Command line interface for PortHamiltonianBenchmarkSystems

## Installation

First, download and install julia from [here](https://julialang.org/downloads/#download_julia) for your operating system. Then install the required packages within a julia session:
```julia
julia> using Pkg
julia> Pkg.add(["ArgParse", "MAT", "LinearAlgebra", "SparseArrays"])
julia> Pkg.add(url="https://github.com/Algopaul/PortHamiltonianBenchmarkSystems.jl/")
```
Then, clone this repository.

## Usage
Navigate to the directory of this repository and call (in your shell and *not* from the julia REPL)
```bash
$ julia phbs_cli.jl --help
```

## Example
To obtain the `.mat`-file of the pH mass-spring-damper chain with `50` cells and a stiffness coefficient `k` of `4.5`, call
```bash
$ julia phbs_cli.jl pH_msd --n_cells 50 --k 4.5
```
Then `PHSystem.mat` file contains the desired system matrices `E, J, R, Q, G, P, S, N`.

A custom filename can be passed via `--filename myCustomName.mat`.
