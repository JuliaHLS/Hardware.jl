module Hardware

using Libdl


# const libxxx= "/usr/local/lib/libHLSCore_C_API.so"
# const lib = dlopen(libxxx)
push!(Libdl.DL_LOAD_PATH, "/usr/local/lib")

include("HLSTool.jl")
include("Synthesise.jl")

export @hardware_synthesise

end # module Hardware
