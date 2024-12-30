using Clang.Generators
using Pkg

cd(@__DIR__)

header = "/usr/local/include/HLS_C_API.hpp"

args = get_default_args()

options = load_options(joinpath(@__DIR__, "generator.toml"))

ctx = create_context(header, args, options)

build!(ctx)

