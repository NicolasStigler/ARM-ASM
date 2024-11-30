`timescale 1ns / 1ps

module floper #(parameter WIDTH = 8) (
  input clk,
  input reset,
  input flush,
  input [WIDTH-1:0] d,
  output [WIDTH-1:0] q
);
  always @(posedge clk or posedge reset) begin
	  if (reset)
		  q <= 0;
	  else if (flush)
		  q <= 0;
	  else
		  q <= d;
	  end
endmodule
