using ArgParse
using MAT
using PortHamiltonianBenchmarkSystems
using LinearAlgebra
using SparseArrays

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "pH_msd"
        help = "pH-MSD benchmark"
        action = :command
        "poro"
        help = "poro elasticity model"
        action = :command
        "--filename"
        help = "pH-MSD benchmark"
        default = "PHSystem.mat"
    end
    # Add config for MSD-Chain
    @add_arg_table s["pH_msd"] begin
        "--n_cells"
        help = "number of msd cells"
        default = 50
        arg_type = Int
        "--io_dim"
        help = "dimension of the input/output"
        default = 2
        arg_type = Int
        "--c"
        help = "damping coefficients"
        default = 1.0
        arg_type = Float64
        "--k"
        help = "stiffnesses"
        default = 4.0
        arg_type = Float64
        "--m"
        help = "masses"
        default = 4.0
        arg_type = Float64
    end
    # Add config for Poro-Model
    @add_arg_table s["poro"] begin
    "--n"
    default = 980
    arg_type = Int
    "--rho"
    default = 1e-3
    arg_type = Float64
    "--alpha"
    default = 0.79
    arg_type = Float64
    "--bm"
    default = 1 / 7.80e3
    arg_type = Float64
    "--kappanu"
    default = 633.33
    arg_type = Float64
    "--eta"
    default = 1e-4
    arg_type = Float64
    end
    return parse_args(s)
end

function save(pH::PHSystem, filename::String)
    matwrite(
        filename,
        Dict([
            "E" => save_as_matrix(pH.E),
            "J" => save_as_matrix(pH.J),
            "R" => save_as_matrix(pH.R),
            "Q" => save_as_matrix(pH.Q),
            "G" => save_as_matrix(pH.G),
            "P" => save_as_matrix(pH.P),
            "S" => save_as_matrix(pH.S),
            "N" => save_as_matrix(pH.N),
        ]),
    )
    return nothing
end

function save_as_matrix(M::Matrix)
    return M
end
function save_as_matrix(M::SparseMatrixCSC)
    return M
end
function save_as_matrix(M::Diagonal)
    return sparse(M)
end
function save_as_matrix(M)
    return Array(M)
end

function pH_selector(parsed_args)
    if parsed_args["%COMMAND%"] == "pH_msd"
        config = SingleMSDConfig(
            parsed_args["pH_msd"]["n_cells"],
            parsed_args["pH_msd"]["io_dim"],
            parsed_args["pH_msd"]["c"],
            parsed_args["pH_msd"]["k"],
            parsed_args["pH_msd"]["m"],
        )
        save(PHSystem(config), parsed_args["filename"])
        return nothing
    elseif parsed_args["%COMMAND%"] == "poro"
        E, J, R, B = poro_elasticity_model(;
            n=parsed_args["poro"]["n"],
            rho=parsed_args["poro"]["rho"],
            alpha=parsed_args["poro"]["alpha"],
            bm=parsed_args["poro"]["bm"],
            kappanu=parsed_args["poro"]["kappanu"],
            eta=parsed_args["poro"]["eta"],
        )
        Q = I(size(E,1))
        n, m = size(B)
        P = spzeros(n, m)
        S = spzeros(m, m)
        N = spzeros(m, m)
        save(PHSystem(E, J, R, Q, B, P, S, N), parsed_args["filename"])
        return nothing
    else
        error("Unknown command: " + parsed_args["%COMMAND%"])
    end
end

function main()
    parsed_args = parse_commandline()
    pH_selector(parsed_args)
end

main()
