include("HLS_IO.jl")

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

function getHLSConfig(tool::HLS)
    return getHLSConfig(tool.opt)
end

function synthesise(tool::HLS, input::String, output::String)
    println("Instantiating HLS tool...")
    tool.opt = HLSCore_IO(input, output)

    println("Setting Options")
    HLSCore.HLSTool_setOptions(tool._tool.ptr, getHLSConfig(tool), tool.opt._inputMlir, tool.opt._outputFilename)

    println("Starting synthesis...")
    if (!HLSCore.HLSTool_synthesise(tool._tool.ptr))
        println("ERROR: Unable to synthesise source code, please check logs for errors")
    end
end

