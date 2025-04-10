module Hardware

using Libdl

push!(Libdl.DL_LOAD_PATH, "/usr/local/lib")

include("HLSTool.jl")
include("Synthesise.jl")

export @hardware_synthesise

end # module Hardware
