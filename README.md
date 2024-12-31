# Hardware.jl


## Dependencies
1. Install CIRCT and its LLVM Dialects
2. Install HLSCore
3. Ensure Access to JMLIRCore

#### Installing CIRCT and its LLVM Dialects
1. Build the latest version of CIRCT and LLVM (https://github.com/llvm/circt)
2. Execute `cd circt/llvm/build`, and `sudo ninja install`
3. Go back to the root directory to execute `cd circt/build` and `sudo ninja install`

#### Installing HLSCore
1. `git clone git@github.com:JuliaHLS/HLSCore.git`
2. `cd HLSCore`
3. `mkdir build`
4. `cd ./build`
5. `cmake ..`
6. `make -j8`
7. `sudo make install`

#### JMLIRCore
Ensure that you have access to the following repository: "https://github.com/JuliaHLS/JMLIRCore". If not, please contact benedict.short21@imperial.ac.uk.
