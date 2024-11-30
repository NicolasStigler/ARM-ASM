`timescale 1ns / 1ps

module controller (
    input wire clk,
    input wire reset,
    input wire [31:12] InstrD,
    input wire [3:0] ALUFlagsE,
    output wire [1:0] RegSrcD,
    output wire [1:0] ImmSrcD,
    output wire ALUSrcE,
    output wire BranchTakenE,
    output wire [4:0] ALUControlE,
    output wire MemWriteM,
    output wire MemtoRegW,
    output wire PCSrcW,
    output wire RegWriteW,
    output wire RegWriteM,
    output wire MemtoRegE,
    output wire PCWPendingF,
    output wire LinkWriteE,
    output wire SpecialInstrE,
    output wire [4:0] SpecialInstrControlE, // New: Pass SpecialInstrControl to Execute stage
    output wire LoadMultipleE,
    output wire StoreMultipleE,
    output wire PreDecrementE,
    output wire PostIncrementE,
    output wire UpdateBaseE,
    input wire FlushE
);
    // Control signals in the Decode stage
    wire [1:0] FlagWriteD, FlagWriteE;
    wire [4:0] ALUControlD, SpecialInstrControlD; // Added SpecialInstrControl
    wire ALUSrcD, MemtoRegD, MemWriteD, RegWriteD, PCSrcD;
    wire SpecialInstrD, BranchD, LinkD, ALUOpD;
    wire LoadMultipleD, StoreMultipleD, PreDecrementD, PostIncrementD, UpdateBaseD;

    // Decode module generates control signals from the instruction
    decode dec(
        .Op(InstrD[27:26]),
        .Funct(InstrD[25:20]),
        .Rd(InstrD[15:12]),
        .FlagW(FlagWriteD),
        .PCS(PCSrcD),
        .RegW(RegWriteD),
        .MemW(MemWriteD),
        .MemtoReg(MemtoRegD),
        .ALUSrc(ALUSrcD),
        .ImmSrc(ImmSrcD),
        .RegSrc(RegSrcD),
        .ALUControl(ALUControlD),
        .LinkWrite(LinkD),
        .SpecialInstr(SpecialInstrD),
        .SpecialInstrControl(SpecialInstrControlD), // Connect new output
        .LoadMultiple(LoadMultipleD),
        .StoreMultiple(StoreMultipleD),
        .PreDecrement(PreDecrementD),
        .PostIncrement(PostIncrementD),
        .UpdateBase(UpdateBaseD)
    );

    // Pass control signals to the Execute stage
    flopenr #(23) regE ( // Increased width for SpecialInstrControl
        .clk(clk),
        .reset(reset),
        .flush(FlushE),
        .d({
            PCSrcD, RegWriteD, MemWriteD, MemtoRegD, ALUSrcD, ALUControlD,
            FlagWriteD, LinkD, SpecialInstrD, SpecialInstrControlD,
            LoadMultipleD, StoreMultipleD, PreDecrementD, PostIncrementD, UpdateBaseD
        }),
        .q({
            PCSrcE, RegWriteE, MemWriteE, MemtoRegE, ALUSrcE, ALUControlE,
            FlagWriteE, LinkWriteE, SpecialInstrE, SpecialInstrControlE,
            LoadMultipleE, StoreMultipleE, PreDecrementE, PostIncrementE, UpdateBaseE
        })
    );

    // Determine if the branch is taken
    condlogic cl(
        .Cond(InstrD[31:28]),
        .Flags(ALUFlagsE),
        .FlagW(FlagWriteE),
        .CondEx(BranchTakenE)
    );
endmodule
