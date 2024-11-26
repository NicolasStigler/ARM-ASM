`timescale 1ns / 1ps

module adder #(parameter WIDTH = 8) (
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	output [WIDTH-1:0] y,
);
	assign y = a + b;
endmodule
