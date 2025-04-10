using JMLIRCore

include("HLS.jl")


function extract_mlir(mlir_ops)::String
    mlir_buffer = IOBuffer()
    print(mlir_buffer, mlir_ops)
    return String(take!(mlir_buffer))
end


macro hardware_synthesise(call, outputFilename = "-"::String, dynamic_scheduling=true)
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
        hardware_synthesise($f, $args, $outputFilename, $dynamic_scheduling)
    end
end


"Synthesise Julia into Verilog"
function hardware_synthesise(f, args, output::String, dynamic_scheduling=true)
    tool::HLS = HLS(dynamic_scheduling)

    mlir_ops = JMLIRCore.code_mlir(f, args)
    inputMLIR = extract_mlir(mlir_ops)

    synthesise(tool, inputMLIR, output)

    # explicitly call garbage collections to ensure
    # that multiple instances of the HLS tool do not
    # live in memory simultaneously
    GC.gc()
end
