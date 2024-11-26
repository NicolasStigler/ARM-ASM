`timescale 1ns / 1ps
`include "arm.v"
`include "imem.v"
`include "dmem.v"

module top (
	input clk;
	input reset;
	output [31:0] WriteDataM;
	output [31:0] DataAdrM;
	output MemWriteM;
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
		.DataAdrM(DataAdrM),
		.WriteDataM(WriteData),
		.ReadDataM(ReadDataM)
	);
	
	imem imem(
		.PCF(PCF),
		.InstrF(InstrF)
	);
	
	dmem dmem(
		.clk(clk),
		.MemWriteM(MemWriteM),
		.DataAdrM(DataAdrM),
		.WriteDataM(WriteDataM),
		.ReadDataM(ReadDataM)
	);
endmodule
