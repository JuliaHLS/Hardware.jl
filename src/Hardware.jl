module Hardware

using Libdl
using JMLIRCore

const libxxx= "/usr/local/lib/libHLSCore_C_API.so"
const lib = dlopen(libxxx)

include("HLSTool.jl")


end # module Hardware
