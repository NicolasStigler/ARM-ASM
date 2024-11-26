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
	output wire [2:0] ALUControlE,
	output wire MemWriteM,
	output wire MemtoRegW,
	output wire PCSrcW,
	output wire RegWriteW,
	output wire RegWriteM,
	output wire MemtoRegE,
	output wire PCWPendingF,
	input wire FlushE
);
	// Control signals en el Decode stage
	wire [1:0] FlagWriteD, FlagWriteE;
    	wire [2:0] ALUControlD;
    	wire ALUSrcD, MemtoRegD, MemWriteD, RegWriteD, PCSrcD;
    	wire BranchD, ALUOpD;

	// Intermediate wires
    	wire [3:0] FlagsE, FlagsNextE, CondE;

	// Decode module genera las control signals apartir de la instruccion
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
		.ALUControl(ALUControlD)
	);

	// Pasar las control signals al Execute stage
	flopenr #(10) regE (
	        .clk(clk),
	        .reset(reset),
	        .en(~FlushE),
	        .d({PCSrcD, RegWriteD, MemWriteD, MemtoRegD, ALUSrcD, ALUControlD, FlagWriteD}),
        	.q({PCSrcE, RegWriteE, MemWriteE, MemtoRegE, ALUSrcE, ALUControlE, FlagWriteE})
    	);

	// Deducir si se tomo el Branch
	condlogic cl(
		.Cond(InstrD[31:28]),
		.ALUFlags(ALUFlagsE),
		.FlagW(FlagWriteE),
		.PCS(PCSrcE),
		.BranchTaken(BranchTakenE)
	);

	// Pasar las signals al Memory stage
	flopr #(5) regM (
	        .clk(clk),
	        .reset(reset),
	        .d({RegWriteE, MemWriteE, MemtoRegE, BranchTakenE}),
	        .q({RegWriteM, MemWriteM, MemtoRegM, BranchTakenM})
	);

	// Pasar las signals al WriteBack stage
    	flopr #(3) regW (
        	.clk(clk),
        	.reset(reset),
        	.d({RegWriteM, MemtoRegM, BranchTakenM}),
        	.q({RegWriteW, MemtoRegW, PCSrcW})
    	);
endmodule
