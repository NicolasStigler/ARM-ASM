`timescale 1ns / 1ps

module arm (
	input wire clk;
	input wire reset;
	output wire [31:0] PC;
	input wire [31:0] InstrF;
	output wire MemWrite;
	output wire [31:0] ALUResultM;
	output wire [31:0] WriteDataM;
	input wire [31:0] ReadData;
);
	wire [3:0] ALUFlags;
	wire RegWrite;
	wire ALUSrc;
	wire MemtoReg;
	wire PCSrc;
	wire [1:0] RegSrc;
	wire [1:0] ImmSrc;
	wire [1:0] ALUControl;

	wire StallF, StallD, StallE, StallM;
    	wire FlushD, FlushE, FlushM;

	wire [1:0] ForwardAE, ForwardBE;

	wire [31:0] InstrD, SrcAE, SrcBE;
    	wire [31:0] ALUResultE, ExtImmE, WriteDataE;
    	wire [3:0] WA3E;

	wire BranchPredicted;
    	wire BranchTaken;
    	wire FlushBranch;
	
	controller c(
		.clk(clk),
		.reset(reset),
		.Instr(InstrD[31:12]),
		.ALUFlags(ALUFlags),
		.RegSrc(RegSrc),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUSrc(ALUSrc),
		.ALUControl(ALUControl),
		.MemWrite(MemWrite),
		.MemtoReg(MemtoReg),
		.PCSrc(PCSrc)
	);

	hazard_unit h (
        	.InstrD(InstrD),
		.InstrE({InstrD[15:0]}), // todavia podria cambiarlo
        	.RegWriteE(RegWrite),
        	.RegWriteM(MemWrite),
        	.ForwardAE(ForwardAE),
        	.ForwardBE(ForwardBE),
        	.StallF(StallF),
        	.StallD(StallD),
        	.StallE(StallE),
        	.FlushD(FlushD),
        	.FlushE(FlushE)
    	);
	
	datapath dp(
		.clk(clk),
		.reset(reset),
		.RegSrc(RegSrc),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUSrc(ALUSrc),
		.ALUControl(ALUControl),
		.MemtoReg(MemtoReg),
		.PCSrc(PCSrc),
		.ALUFlags(ALUFlags),
		.PC(PC),
		.InstrF(InstrF),
		.ALUResultM(ALUResultM),
        	.WriteDataM(WriteDataM),
        	.ReadData(ReadData),
        	.StallF(StallF),
        	.FlushD(FlushD),
        	.StallD(StallD),
        	.FlushE(FlushE),
        	.StallE(StallE),
        	.FlushM(FlushM)
	);

	branch_predictor bp (
        	.clk(clk),
        	.reset(reset),
        	.InstrF(InstrF),
        	.BranchPredicted(BranchPredicted),
        	.BranchTaken(BranchTaken),
        	.FlushBranch(FlushBranch)
    	);

	assign FlushD = FlushBranch;
endmodule
