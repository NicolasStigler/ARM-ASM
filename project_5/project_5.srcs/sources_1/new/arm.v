`timescale 1ns / 1ps
`include "controller.c"
`include "datapath.v"

module arm (
	input clk;
	input reset;
	output [31:0] PCF;
	input [31:0] InstrF;
	output MemWriteM;
	output [31:0] ALUResultM;
	output [31:0] WriteDataM;
	input [31:0] ReadDataM;
);
	wire [1:0] RegSrcD;
	wire [1:0] ImmSrcD;
	wire [2:0] ALUControlE;
	wire ALUSrcE, BranchTakenE, MemtoRegW, PCSrcW, RegWriteW;
	wire [3:0] ALUFlagsE;
	wire [31:0] InstrD;
	wire RegWriteM, MemtoRegE, PCWPendingF;
	wire [1:0] ForwardAE, ForwardBE;
	wire StallF, StallD, FlushD, FlushE;
	wire Check1_EM, Check1_EW, Check2_EM, Check2_EW, Check12_DE;
	
	controller c(
		.clk(clk),
		.reset(reset),
		.InstrD(InstrD[31:12]),
		.ALUFlagsE(ALUFlagsE),
		.RegSrcD(RegSrcD),
		.ImmSrcD(ImmSrcD),
		.ALUSrcE(ALUSrcE),
		.BranchTakenE(BranchTakenE),
		.ALUControlE(ALUControlE),
		.MemWriteM(MemWriteM),
		.MemtoRegW(MemtoRegW),
		.PCSrcW(PCSrcW),
		.RegWriteW(RegWriteW),
		.RegWriteM(RegWriteM), 
	    	.MemtoRegE(MemtoRegE), 
	    	.PCWPendingF(PCWPendingF), 
	    	.FlushE(FlushE)
	);
	
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
