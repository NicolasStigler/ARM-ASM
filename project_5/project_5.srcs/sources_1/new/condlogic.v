`timescale 1ns / 1ps
`include "condcheck.v"

module condlogic(
	input [3:0] Cond,
	input [3:0] Flags,
	input [3:0] ALUFlags,
	input [1:0] FlagW,
	output wire CondEx,
	output [3:0] FlagsNext
);
	condcheck cc(
		.Cond(Cond),
		.Flags(Flags),
		.CondEx(CondEx)
	);

	// Logica para actualizar las flags
	assign FlagsNext[3:2] = (FlagW[1] & CondEx) ? ALUFlags[3:2] : Flags[3:2];
	assign FlagsNext[1:0] = (FlagW[0] & CondEx) ? ALUFlags[1:0] : Flags[1:0];
endmodule
