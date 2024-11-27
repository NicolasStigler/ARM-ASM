`timescale 1ns / 1ps
`include "mux2.v"

module datapath (
    input clk,
    input reset,
    input [1:0] RegSrcD,
    input [1:0] ImmSrcD,
    input ALUSrcE,
    input BranchTakenE,
    input [4:0] ALUControlE, // Updated to match 5-bit ALU control
    input MemtoRegW,
    input MemtoRegE, // Added to manage MemtoReg in the execute stage
    input PCSrcW,
    input RegWriteW,
    input UpdateBaseE, // Signal to update the base register in post-indexed mode
    output [31:0] PCF,
    input [31:0] InstrF,
    output [31:0] InstrD,
    output [31:0] ALUResultM,
    output [31:0] WriteDataM,
    input [31:0] ReadDataM,
    output [3:0] ALUFlagsE,
    output Check1_EM, Check1_EW, Check2_EM, Check2_EW, Check12_DE,
    input [1:0] ForwardAE, ForwardBE,
    input StallF, StallD, FlushD
);
    // Internal signals
    wire [31:0] PCPlus4F, PCNext1F, PCNextF;
    wire [31:0] ExtImmD, rd1D, rd2D, PCPlus8D;
    wire [31:0] rd1E, rd2E, ExtImmE, SrcAE, SrcBE, WriteDataE, ALUResultE;
    wire [31:0] ReadDataW, ALUResultW, ResultW;
    wire [31:0] UpdatedBaseE, UpdatedBaseM, UpdatedBaseW; // Updated base register for post-indexed mode
    wire [3:0] RA1D, RA2D, RA1E, RA2E, WA3E, WA3M, WA3W;
    wire Check1_DE, Check2_DE;

    // Fetch Stage
    mux2 #(32) PCNextMux(PCPlus4F, ResultW, PCSrcW, PCNext1F); 
    mux2 #(32) BranchMux(PCNext1F, ALUResultE, BranchTakenE, PCNextF); 
    floper #(32) PCReg(clk, reset, ~StallF, PCNextF, PCF); 
    adder #(32) PCAdd(PCF, 32'b0100, PCPlus4F);

    assign PCPlus8D = PCPlus4F;

    // Decode Stage
    flopenr #(32) InstReg(clk, reset, ~StallD, FlushD, InstrF, InstrD); 
    mux2 #(4) RA1Mux(InstrD[19:16], 4'b1111, RegSrcD[0], RA1D); 
    mux2 #(4) RA2Mux(InstrD[3:0], InstrD[15:12], RegSrcD[1], RA2D); 
    regfile rf(clk, RegWriteW, RA1D, RA2D, WA3W, ResultW, PCPlus8D, rd1D, rd2D); 
    extend extender(InstrD[23:0], ImmSrcD, ExtImmD); 

    // Execute Stage
    flopr #(32) rd1Reg(clk, reset, rd1D, rd1E); 
    flopr #(32) rd2Reg(clk, reset, rd2D, rd2E); 
    flopr #(32) ImmReg(clk, reset, ExtImmD, ExtImmE);
    flopr #(4) WA3EReg(clk, reset, InstrD[15:12], WA3E); 
    flopr #(4) RA1Reg(clk, reset, RA1D, RA1E); 
    flopr #(4) RA2Reg(clk, reset, RA2D, RA2E); 
    mux3 #(32) bypass1Mux(rd1E, ResultW, ALUResultM, ForwardAE, SrcAE); 
    mux3 #(32) bypass2Mux(rd2E, ResultW, ALUResultM, ForwardBE, WriteDataE); 
    mux2 #(32) SecSrc(WriteDataE, ExtImmE, ALUSrcE, SrcBE); 
    alu alu(SrcAE, SrcBE, ALUControlE, ALUResultE, UpdatedBaseE, ALUFlagsE); 

    // Memory Stage
    flopr #(32) ALUResultReg(clk, reset, ALUResultE, ALUResultM); 
    flopr #(32) WriteDataReg(clk, reset, WriteDataE, WriteDataM); 
    flopr #(4) WA3MReg(clk, reset, WA3E, WA3M); 
    flopr #(32) UpdatedBaseReg(clk, reset, UpdatedBaseE, UpdatedBaseM); 

    // Writeback Stage
    flopr #(32) ALUResultRegW(clk, reset, ALUResultM, ALUResultW); 
    flopr #(32) ReadDataReg(clk, reset, ReadDataM, ReadDataW); 
    flopr #(4) WA3WReg(clk, reset, WA3M, WA3W); 
    flopr #(32) UpdatedBaseRegW(clk, reset, UpdatedBaseM, UpdatedBaseW); 
    mux2 #(32) ResMux(ALUResultW, ReadDataW, MemtoRegW, ResultW); 

    // Update base register in post-indexed mode
    wire [31:0] FinalResultW;
    mux2 #(32) UpdateBaseMux(ResultW, UpdatedBaseW, UpdateBaseE, FinalResultW);

    // Hazard unit checks
    equaler #(4) c0(WA3M, RA1E, Check1_EM); 
    equaler #(4) c1(WA3W, RA1E, Check1_EW); 
    equaler #(4) c2(WA3M, RA2E, Check2_EM); 
    equaler #(4) c3(WA3W, RA2E, Check2_EW); 
    equaler #(4) c4a(WA3E, RA1D, Check1_DE); 
    equaler #(4) c4b(WA3E, RA2D, Check2_DE); 
    assign Check12_DE = Check1_DE | Check2_DE;
endmodule
