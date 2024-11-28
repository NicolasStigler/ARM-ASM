`timescale 1ns / 1ps
`include "arm.v"
`include "imem.v"
`include "dmem.v"

module top (
    input clk,
    input reset,
    output [31:0] WriteDataM, // Data to be written to memory
    output [31:0] DataAdrM,   // Address for memory operations
    output MemWriteM          // Memory write enable
);
    wire [31:0] PCF;          // Program Counter from Fetch stage
    wire [31:0] InstrF;       // Instruction from Fetch stage
    wire [31:0] ReadDataM;    // Data read from memory

    // Instantiate ARM processor
    arm arm(
        .clk(clk),
        .reset(reset),
        .PCF(PCF),
        .InstrF(InstrF),
        .MemWriteM(MemWriteM),
        .ALUResultM(DataAdrM),   // ALUResultM is connected to DataAdrM
        .WriteDataM(WriteDataM),
        .ReadDataM(ReadDataM)
    );

    // Instruction memory instantiation
    imem imem(
        .adr(PCF),
        .rd(InstrF)
    );

    // Data memory instantiation
    dmem dmem(
        .clk(clk),
        .we(MemWriteM),
        .adr(DataAdrM),
        .wd(WriteDataM),
        .rd(ReadDataM)
    );
endmodule
