`timescale 1ns / 1ps
`include "decode.v"

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
    output wire LoadMultipleE,      // New: Signal for LDM instructions
    output wire StoreMultipleE,     // New: Signal for STM instructions
    output wire PreDecrementE,      // New: Addressing mode for decrement before
    output wire PostIncrementE,     // New: Addressing mode for increment after
    output wire UpdateBaseE,        // New: Update base register after memory access
    input wire FlushE
);
    // Control signals in the Decode stage
    wire [1:0] FlagWriteD, FlagWriteE;
    wire [4:0] ALUControlD;
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
        .LoadMultiple(LoadMultipleD),       // New signal for LDM
        .StoreMultiple(StoreMultipleD),     // New signal for STM
        .PreDecrement(PreDecrementD),       // New signal for addressing mode
        .PostIncrement(PostIncrementD),     // New signal for addressing mode
        .UpdateBase(UpdateBaseD)            // New signal to update base register
    );

    // Pass control signals to the Execute stage
    flopenr #(18) regE ( // Increased width to include new control signals
        .clk(clk),
        .reset(reset),
        .flush(FlushE),
        .d({
            PCSrcD, RegWriteD, MemWriteD, MemtoRegD, ALUSrcD, ALUControlD,
            FlagWriteD, LinkD, SpecialInstrD, LoadMultipleD, StoreMultipleD,
            PreDecrementD, PostIncrementD, UpdateBaseD
        }),
        .q({
            PCSrcE, RegWriteE, MemWriteE, MemtoRegE, ALUSrcE, ALUControlE,
            FlagWriteE, LinkWriteE, SpecialInstrE, LoadMultipleE, StoreMultipleE,
            PreDecrementE, PostIncrementE, UpdateBaseE
        })
    );

    // Determine if the branch is taken
    condlogic cl(
        .Cond(InstrD[31:28]),
        .ALUFlags(ALUFlagsE),
        .FlagW(FlagWriteE),
        .PCS(PCSrcE),
        .BranchTaken(BranchTakenE)
    );

    // Pass signals to the Memory stage
    flopr #(9) regM ( // Increased width for new control signals
        .clk(clk),
        .reset(reset),
        .d({
            RegWriteE, MemWriteE, MemtoRegE, BranchTakenE, SpecialInstrE,
            LoadMultipleE, StoreMultipleE, UpdateBaseE
        }),
        .q({
            RegWriteM, MemWriteM, MemtoRegM, BranchTakenM, SpecialInstrM,
            LoadMultipleM, StoreMultipleM, UpdateBaseM
        })
    );

    // Pass signals to the WriteBack stage
    flopr #(5) regW ( // Increased width for new control signals
        .clk(clk),
        .reset(reset),
        .d({RegWriteM, MemtoRegM, BranchTakenM, SpecialInstrM, UpdateBaseM}),
        .q({RegWriteW, MemtoRegW, PCSrcW, SpecialInstrW, UpdateBaseW})
    );

endmodule
