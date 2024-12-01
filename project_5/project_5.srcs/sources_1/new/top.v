`timescale 1ns / 1ps
`include "arm.v"
`include "imem.v"
`include "dmem.v"

module top (
	input wire clk,
	input wire reset,
	output wire [31:0] WriteDataM,
	output wire [31:0] DataAdrM,
	output wire MemWriteM
);
	wire [31:0] PCF;
	wire [31:0] InstrF;
	wire [31:0] ReadDataM;
	
	arm arm(
		.clk(clk),
		.reset(reset),
		.PCF(PCF),
		.InstrF(InstrF),
		.MemWriteM(MemWriteM),
		.ALUResultM(DataAdrM),
		.WriteDataM(WriteDataM),
		.ReadDataM(ReadDataM)
	);
	
	imem imem(
		.adr(PCF),
		.rd(InstrF)
	);
	
	dmem dmem(
		.clk(clk),
		.we(MemWriteM),
		.adr(DataAdrM),
		.wd(WriteDataM),
		.rd(ReadDataM)
	);
endmodule
