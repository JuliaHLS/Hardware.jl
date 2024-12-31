using Libdl
using JMLIRCore

const libxxx= "/usr/local/lib/libHLSCore_C_API.so"
const lib = dlopen(libxxx)

include("HLSTool.jl")

function extract_mlir(mlir_ops)::String
    mlir_buffer = IOBuffer()
    print(mlir_buffer, mlir_ops)
    return String(take!(mlir_buffer))
end


macro hardware_synthesise(call, outputFilename = "-"::String)
    @assert Meta.isexpr(call, :call) "only calls are supported"

    f = esc(first(call.args))
    args = esc(
        Expr(
            :curly,
            Tuple,
            map(arg -> :($(Core.Typeof)($arg)), call.args[(begin + 1):end])...,
        ),
    )

    quote
        hardware_synthesise($f, $args, $outputFilename)
    end
end


"Synthesise Julia into Verilog"
function hardware_synthesise(f, input_types, outputFilename = "-"::String)
    # preprocess mlir
    mlir_ops = code_mlir(f, input_types)
    mlir_str = extract_mlir(mlir_ops)

    # set up the HLS tool
    tool = HLSTool_create()
    HLSTool_setOptions(tool, mlir_str, outputFilename)


    # synthesise
    HLSTool_synthesise(tool)

    # Clean up
    HLSTool_destroy(tool)
end
