# generate the Bindings for HLSTool
make_bindings_path = joinpath(@__DIR__, "./bindings/make_bindings.jl")
include(make_bindings_path)
