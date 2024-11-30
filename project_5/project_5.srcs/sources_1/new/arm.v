`timescale 1ns / 1ps

module arm (
    input clk,                  // Clock signal
    input reset,                // Reset signal
    output [31:0] PCF,          // Program Counter (Fetch stage)
    input [31:0] InstrF,        // Instruction from Fetch stage
    output MemWriteM,           // Memory write enable (Memory stage)
    output [31:0] ALUResultM,   // ALU result (Memory stage)
    output [31:0] WriteDataM,   // Data to be written to memory (Memory stage)
    input [31:0] ReadDataM      // Data read from memory (Memory stage)
);

    // Control signals
    wire [1:0] RegSrcD;         // Register source for Decode stage
    wire [1:0] ImmSrcD;         // Immediate source for Decode stage
    wire [2:0] ALUControlE;     // ALU control signal for Execute stage
    wire ALUSrcE, BranchTakenE, MemtoRegW, PCSrcW, RegWriteW;
    wire [3:0] ALUFlagsE;       // ALU flags from Execute stage

    // Data signals
    wire [31:0] InstrD;         // Instruction (Decode stage)
    wire RegWriteM, MemtoRegE, PCWPendingF;

    // Hazard unit signals
    wire [1:0] ForwardAE, ForwardBE; // Forwarding signals for ALU inputs
    wire StallF, StallD, FlushD, FlushE; // Stall and flush signals
    wire Check1_EM, Check1_EW, Check2_EM, Check2_EW, Check12_DE; // Hazard checks

    // Controller instantiation
    controller c(
        .clk(clk),
        .reset(reset),
        .InstrD(InstrD[31:12]),   // Instruction bits for control decoding
        .ALUFlagsE(ALUFlagsE),    // ALU flags from Execute stage
        .RegSrcD(RegSrcD),        // Register source control for Decode stage
        .ImmSrcD(ImmSrcD),        // Immediate source control for Decode stage
        .ALUSrcE(ALUSrcE),        // ALU source control for Execute stage
        .BranchTakenE(BranchTakenE), // Branch decision
        .ALUControlE(ALUControlE),  // ALU control signal
        .MemWriteM(MemWriteM),      // Memory write enable
        .MemtoRegW(MemtoRegW),      // Mem-to-reg control for Writeback stage
        .PCSrcW(PCSrcW),            // Program Counter source (Writeback stage)
        .RegWriteW(RegWriteW),      // Register write enable (Writeback stage)
        .RegWriteM(RegWriteM),      // Register write enable (Memory stage)
        .MemtoRegE(MemtoRegE),      // Mem-to-reg control for Execute stage
        .PCWPendingF(PCWPendingF),  // Program Counter write pending
        .FlushE(FlushE)             // Flush signal for Execute stage
    );

    // Datapath instantiation
    datapath dp(
        .clk(clk),
        .reset(reset),
        .RegSrcD(RegSrcD),
        .ImmSrcD(ImmSrcD),
        .ALUSrcE(ALUSrcE),
        .BranchTakenE(BranchTakenE),
        .ALUControlE(ALUControlE),
        .MemtoRegW(MemtoRegW),
        .PCSrcW(PCSrcW),
        .RegWriteW(RegWriteW),
        .PCF(PCF),
        .InstrF(InstrF),
        .InstrD(InstrD),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .ReadDataM(ReadDataM),
        .ALUFlagsE(ALUFlagsE),
        .Check1_EM(Check1_EM),
        .Check1_EW(Check1_EW),
        .Check2_EM(Check2_EM),
        .Check2_EW(Check2_EW),
        .Check12_DE(Check12_DE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD)
    );

    // Hazard unit instantiation
    hazardunit h(
        .clk(clk),
        .reset(reset),
        .Check1_EM(Check1_EM),
        .Check1_EW(Check1_EW),
        .Check2_EM(Check2_EM),
        .Check2_EW(Check2_EW),
        .Check12_DE(Check12_DE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .BranchTakenE(BranchTakenE),
        .MemtoRegE(MemtoRegE),
        .PCWPendingF(PCWPendingF),
        .PCSrcW(PCSrcW),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );
endmodule
