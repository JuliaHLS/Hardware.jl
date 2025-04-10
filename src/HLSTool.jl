module HLSCore

using CEnum

@cenum DynamicParallelismKind::UInt32 begin
    None = 0x0000000000000000
    Locking = 0x0000000000000001
    Pipelining = 0x0000000000000002
end

@cenum OutputFormatKind::UInt32 begin
    OutputIR = 0x0000000000000000
    OutputVerilog = 0x0000000000000001
    OutputSplitVerilog = 0x0000000000000002
end

@cenum SchedulingKind::UInt32 begin
    Static = 0x0000000000000000
    Dynamic = 0x0000000000000001
end

@cenum IRLevel::UInt32 begin
    High = 0x0000000000000000
    PreCompile = 0x0000000000000001
    Core = 0x0000000000000002
    PostCompile = 0x0000000000000003
    RTL = 0x0000000000000004
    SV = 0x0000000000000005
end

struct HLSConfig
    withESI::Bool
    dynParallelism::DynamicParallelismKind
    bufferingStrategy::Ptr{Cchar}
    bufferSize::Cuint
    irInputLevel::IRLevel
    irOutputLevel::IRLevel
    splitInputFile::Bool
    outputFormat::OutputFormatKind
    traceIVerilog::Bool
    withDC::Bool
    verifyPasses::Bool
    verifyDiagnostics::Bool
    runtime_logs::Bool
end

mutable struct HLSTool end

function HLSTool_create(_schedulingKind)
    ccall((:HLSTool_create, "libHLSCore_C_API.so"), Ptr{HLSTool}, (SchedulingKind,), _schedulingKind)
end

function HLSTool_destroy(_tool)
    ccall((:HLSTool_destroy, "libHLSCore_C_API.so"), Cvoid, (Ptr{HLSTool},), _tool)
end

function HLSTool_setOptions(tool, options, inputMLIR, output)
    ccall((:HLSTool_setOptions, "libHLSCore_C_API.so"), Cvoid, (Ptr{HLSTool}, Ptr{HLSConfig}, Ptr{Cchar}, Ptr{Cchar}), tool, options, inputMLIR, output)
end

function HLSTool_synthesise(tool)
    ccall((:HLSTool_synthesise, "libHLSCore_C_API.so"), Bool, (Ptr{HLSTool},), tool)
end

end # module
