using Libdl
using JMLIRCore
using Core
import Base.pointer

include("HLSTool.jl")
# using .HLSCore: DynamicParallelismKind, OutputFormatKind, IRLevel

""" Extract a ptr to an immutable struct """
function Base.pointer(opt::Hardware.HLSCore.HLSConfig)
    Base.unsafe_convert(Ptr{HLSCore.HLSConfig}, Ref(opt))
end

# This struct manages the lifetimes of pointers and objects
# passed into the C-API. This ensures that all the lifetimes
# of the objects and their pointers are grouped together by a
# single strong reference - the struct
""" HLS Options Struct I/O """
struct HLSCore_IO
    # public interface
    function HLSCore_IO(inputMlir::String, outputFilename::String) 
        _inputMlir = inputMlir
        _outputFilename = outputFilename

        _opt = _createHLSConfig()

        new(_opt, _inputMlir, _outputFilename)
    end


    # private data members
    _opt::HLSCore.HLSConfig
    _inputMlir::String
    _outputFilename::String
end

function _createHLSConfig()
    opt = HLSCore.HLSConfig(
        false,
        HLSCore.DynamicParallelismKind(2),
        pointer("all"),
        2,
        HLSCore.IRLevel(0),
        HLSCore.IRLevel(5),
        false,
        HLSCore.OutputFormatKind(1),
        false,
        false,
        true,
        false,
        true
    )


    return opt
end

function getOptionsPtr(opt::HLSCore_IO)::Ptr{HLSCore.HLSConfig}
    return pointer(opt._opt)
end

mutable struct HLSToolWrapper
    ptr::Ptr{HLSCore.HLSTool}
end

# HLS struct once again ensuring consistent memory
# lifetimes by pinning them in the GC via a strong
# reference
mutable struct HLS
    function HLS()
        println("Instantiating HLS Tool")
        _tool = HLSToolWrapper(HLSCore.HLSTool_create())

        # register destructor
        finalizer(_tool::HLSToolWrapper) do tool::HLSToolWrapper
            println("Deleting the HLSTool")
            HLSCore.HLSTool_destroy(tool.ptr)
        end

        # do not use union splitting on the HLSCore_IO, otherwise
        # it will retrieve the incorrect ptr
        new(_tool, HLSCore_IO("", "-"))
    end

    _tool::HLSToolWrapper
    opt::HLSCore_IO
end


function synthesise(tool::HLS, input::String, output::String)
    println("Instantiating HLS tool...")
    tool.opt = HLSCore_IO(input, output)


    println("opt level: ", tool.opt._opt.irInputLevel)

    println("Setting Options")
    HLSCore.HLSTool_setOptions(tool._tool.ptr, Ref(tool.opt._opt), tool.opt._inputMlir, tool.opt._outputFilename)

    println("Starting synthesis...")
    if (!HLSCore.HLSTool_synthesise(tool._tool.ptr))
        println("ERROR: Unable to synthesise source code, please check logs for errors")
    end
end




function extract_mlir(mlir_ops)::String
    mlir_buffer = IOBuffer()
    print(mlir_buffer, mlir_ops)
    return String(take!(mlir_buffer))
end


macro hardware_synthesise(call, outputFilename = "-"::String)
    @assert Meta.isexpr(call, :call) "only calls are supported"

    println("here")

    println("Using call: ", call)
    println("Using args: ", call.args[begin+1:end])

    for arg in call.args[begin+1:end]
        println("Using arg type: ", arg)
        println("Got arg type: ", Core.Typeof(arg))
    end

    f = esc(first(call.args))

    println("set f")
    args = esc(
        Expr(
            :curly,
            Tuple,
            map(arg -> :($(Core.Typeof)($arg)), call.args[(begin + 1):end])...,
        ),
    )
    println("Extracted")

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
