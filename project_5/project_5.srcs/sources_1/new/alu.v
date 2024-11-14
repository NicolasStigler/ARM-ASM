`timescale 1ns / 1ps

module alu (
    input [31:0] a,
    b,
    input [1:0] ALUControl,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags
);
  wire neg, zero, carry, overflow;
  wire [31:0] sum, condinvb, res_sub, res_reverse_sub;
  wire [32:0] sum_extended;

  assign condinvb = ALUControl[0] ? ~b : b;
  assign sum_extended = a + condinvb + ALUControl[0];
  assign res_sub = a + (~b + 1);
  assign res_reverse_sub = a + (~b + 1);

  always @(*) begin
    casex (ALUControl)
      3'b000: Result = sum_extended[31:0];
      3'b001: Result = res_sub;
      3'b010: Result = a & b;
      3'b011: Result = a | b;
      3'b100: Result = a ^ b;
      3'b101: Result = ~(a ^ b);
      3'b110: Result = res_reverse_sub;
      default: Result = 32'b0;
    endcase
  end

  assign neg = Result[31];
  assign zero = (Result == 32'b0);
  assign carry = (ALUControl[0] == 1'b0) & sum_extended[32];
  assign overflow = (ALUControl[0] == 1'b0) & ((a[31] & b[31] & ~Result[31]) | (~a[31] & ~b[31] & Result[31]));
  assign ALUFlags = {neg, zero, carry, overflow};
endmodule
