# Abstract the HLSTool IO, and manage lifetimes of 
# objects

include("HLSTool.jl")

#### Helper Functions ####
""" Extract a ptr to an immutable struct """
function Base.pointer(opt::Hardware.HLSCore.HLSConfig)
    Base.unsafe_convert(Ptr{HLSCore.HLSConfig}, Ref(opt))
end

function _createHLSConfig()::HLSCore.HLSConfig
    return HLSCore.HLSConfig(
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

        opt = _createHLSConfig()

        new(opt, _inputMlir, _outputFilename)
    end


    # private data members
    opt::HLSCore.HLSConfig
    _inputMlir::String
    _outputFilename::String
end


#### Dynamic Dispatch Methods ####

""" return the HLSConfig as a reference (lifetime management, lives as long as the struct)"""
function getHLSConfig(opt::HLSCore_IO)
    return Ref(opt.opt)
end

