`timescale 1ns / 1ps

module alu (
    input [31:0] a, b,
    input [2:0] ALUControl,
    output [31:0] Result,
    output [3:0] Flags // Negative, Zero, Carry, oVerflow
);
    reg neg, zero, carry, overflow;
    reg [31:0] bGated;
    reg [32:0] sum;

    always @(*) begin
        bGated = (ALUControl[0] == 1'b1) ? ~b : b;
    end

    always @(*) begin
        sum = a + bGated + ALUControl[0];
    end
    
    always @(*) begin
        case (ALUControl[2:0])
            3'b000: Result = sum[31:0]; // ADD
            3'b010: Result = a & b; // AND
            3'b011: Result = a | b; // OR
            3'b100: Result = a ^ b; // XOR
            3'b101: Result = a & ~b; // AND NOT b
            default: Result = 32'b0; // NOP
        endcase
    end

    always @(*) begin
        neg = Result[31];
        zero = (Result == 32'b0);
        carry = (ALUControl[1] == 1'b0) & sum[32];
        overflow = (ALUControl[1] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    end

    assign Flags = {neg, zero, carry, overflow};    
endmodule
