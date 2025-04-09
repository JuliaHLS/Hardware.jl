using JMLIRCore

include("HLS.jl")


function extract_mlir(mlir_ops)::String
    mlir_buffer = IOBuffer()
    print(mlir_buffer, mlir_ops)
    return String(take!(mlir_buffer))
end


macro hardware_synthesise(call, outputFilename = "-"::String)
    @assert Meta.isexpr(call, :call) "only calls are supported"

    for arg in call.args[begin+1:end]
        println("Using arg type: ", arg)
        println("Got arg type: ", Core.Typeof(arg))
    end

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
function hardware_synthesise(f, args, output::String)
    tool::HLS = HLS()

    mlir_ops = JMLIRCore.code_mlir(f, args)
    inputMLIR = extract_mlir(mlir_ops)

    synthesise(tool, inputMLIR, output)

    # explicitly call garbage collections to ensure
    # that multiple instances of the HLS tool do not
    # live in memory simultaneously
    GC.gc()
end
