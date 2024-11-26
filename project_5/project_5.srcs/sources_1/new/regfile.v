`timescale 1ns / 1ps

module regfile (
	input clk,
	input we3,
	input [3:0] ra1, ra2, wa3,
	input [31:0] wd3, r15,
	output [31:0] rd1, rd2
);
	reg [31:0] rf [0:14]; // register file de 15 elementos

	// Op de escritura
	always @(negedge clk) begin
		if (we3)
			rf[wa3] <= wd3;
	end

	// Ops de lectura
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule
