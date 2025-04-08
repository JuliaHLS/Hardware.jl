# Hardware.jl

## Generating Bindings
We use `Clang.jl` to automatically generate the C bindings. Please run this with the latest stable version of Julia (v0.11.0) instead of the nightly. This is because `Clang.jl` has not been updated to use the latest version of LLVM yet, and is pinned to `LLVM 16`. This cannot simply be bumped, due to the significant changes made between `LLVM 16` and `LLVM 17`.

## Dependencies
1. Install HLSCore
2. Ensure Access to JMLIRCore
3. `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib`

## Installing HLSCore
1. `git clone git@github.com:JuliaHLS/HLSCore.git`
2. `cd HLSCore`
3. `mkdir build`
4. `cd ./build`
5. `cmake ..`
6. `make -j8`
7. `sudo make install`

#### JMLIRCore
Ensure that you have access to the following repository: "https://github.com/JuliaHLS/JMLIRCore". If not, please contact benedict.short21@imperial.ac.uk.
