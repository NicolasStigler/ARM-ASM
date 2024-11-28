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
    output wire [4:0] ALUControlE, // Updated to match 5-bit ALU control
    output wire MemWriteM,
    output wire MemtoRegW,
    output wire PCSrcW,
    output wire RegWriteW,
    output wire RegWriteM,
    output wire MemtoRegE,
    output wire PCWPendingF,
    output wire LinkWriteE,        // Signal to write link register for BL
    input wire FlushE
);
    // Control signals in the Decode stage
    wire [1:0] FlagWriteD, FlagWriteE;
    wire [4:0] ALUControlD; // Updated to 5 bits
    wire ALUSrcD, MemtoRegD, MemWriteD, RegWriteD, PCSrcD;
    wire BranchD, LinkD, ALUOpD;

    // Intermediate wires
    wire [3:0] FlagsE, FlagsNextE, CondE;

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
        .Link(LinkD) // Signal for BL (Branch with Link)
    );

    // Pass control signals to the Execute stage
    flopenr #(12) regE ( // Increased width to include LinkD and PCSrcD
        .clk(clk),
        .reset(reset),
        .flush(FlushE),
        .d({PCSrcD, RegWriteD, MemWriteD, MemtoRegD, ALUSrcD, ALUControlD, FlagWriteD, LinkD}),
        .q({PCSrcE, RegWriteE, MemWriteE, MemtoRegE, ALUSrcE, ALUControlE, FlagWriteE, LinkWriteE})
    );

    // Determine if the branch is taken
    condlogic cl(
        .Cond(InstrD[31:28]), // Condition field from instruction
        .ALUFlags(ALUFlagsE), // Flags generated in Execute stage
        .FlagW(FlagWriteE),   // Flag write enable from Execute stage
        .PCS(PCSrcE),         // Determines if a branch is required
        .BranchTaken(BranchTakenE) // Output: whether the branch is taken
    );

    // Pass signals to the Memory stage
    flopr #(5) regM (
        .clk(clk),
        .reset(reset),
        .d({RegWriteE, MemWriteE, MemtoRegE, BranchTakenE}),
        .q({RegWriteM, MemWriteM, MemtoRegM, BranchTakenM})
    );

    // Pass signals to the WriteBack stage
    flopr #(3) regW (
        .clk(clk),
        .reset(reset),
        .d({RegWriteM, MemtoRegM, BranchTakenM}),
        .q({RegWriteW, MemtoRegW, PCSrcW})
    );
endmodule
