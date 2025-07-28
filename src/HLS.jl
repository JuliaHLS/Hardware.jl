# High level interface to the HLS tool, including lifetime management

include("HLS_IO.jl")

#### Structs ####
""" Wrap the HLSTool ptr to help with lifetime management """
mutable struct _HLSToolWrapper
    ptr::Ptr{HLSCore.HLSTool}
end

# HLS struct once again ensuring consistent memory
# lifetimes by pinning them in the GC via a strong
# reference
""" HLS driver """
mutable struct HLS
    function HLS(dynamic_scheduling::Bool)
        scheduling = HLSCore.SchedulingKind(dynamic_scheduling)
        println("Instantiating HLS Tool")
        _tool = _HLSToolWrapper(HLSCore.HLSTool_create(scheduling))

        # register destructor
        finalizer(_tool::_HLSToolWrapper) do tool::_HLSToolWrapper
            println("Cleaning up")
            HLSCore.HLSTool_destroy(tool.ptr)
        end

        # do not use union splitting on the HLSCore_IO, otherwise
        # it will retrieve the incorrect ptr
        new(_tool, HLSCore_IO("", "-"))
    end

    _tool::_HLSToolWrapper
    opt::HLSCore_IO
end


#### Dynamic Dispatch Methods ####

""" abstract away the HLSConfig """
function getHLSConfig(tool::HLS)
    return getHLSConfig(tool.opt)
end

""" Invoke synthesis """
function synthesise(tool::HLS, input::String, output::String)
    println("Invoking HLS toolchain")
    tool.opt = HLSCore_IO(input, output)

    println("Setting Options")
    HLSCore.HLSTool_setOptions(tool._tool.ptr, getHLSConfig(tool), tool.opt._inputMlir, tool.opt._outputFilename)

    println("Starting synthesis...")
    if (!HLSCore.HLSTool_synthesise(tool._tool.ptr))
        println("ERROR: Unable to synthesise source code, please check logs for errors")
    end

    println("Synthesis successful: files written to $output")
end

