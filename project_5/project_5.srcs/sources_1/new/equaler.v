`timescale 1ns / 1ps

module equaler #(parameter WIDTH = 8) (
  input [WIDTH-1:0] a,
  input [WIDTH-1:0] b,
  output wire y
);
  assign y = (a == b);
endmodule
