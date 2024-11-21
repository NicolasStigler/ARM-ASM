`timescale 1ns / 1ps

module alu (
    input signed [31:0] a, b,
    input [3:0] ALUControl,
    input Saturated,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags // Negative, Zero, Carry, oVerflow
);
    wire [31:0] condinvb;
    wire [32:0] sum_extended;
    wire [31:0] logic_result;
    wire signed [31:0] saturated_sum;
    wire signed [31:0] saturated_sub;

    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum_extended = {1'b0, a} + {1'b0, condinvb} + ALUControl[0]; // {1'b0, num}: num -> 0num
    assign saturated_sum = (sum_extended[31] == 1'b0 && sum_extended[30:0] > $signed(32'b01111111111111111111111111111111)) ? 32'b01111111111111111111111111111111 : (sum_extended[31] == 1'b1 && sum_extended[30:0] < $signed(32'h10000000000000000000000000000000)) ? 32'h10000000000000000000000000000000 : sum_extended[31:0];
    assign saturated_sub = (a > 0 && b < 0 && a - b < 0) ? 32'b01111111111111111111111111111111 : (a < 0 && b > 0 && a - b > 0) ? 32'h10000000000000000000000000000000 : a - b;
    assign logic_result = (ALUControl[1:0] == 2'b00) ? a & b : (ALUControl[1:0] == 2'b01) ? a | b : (ALUControl[1:0] == 2'b10) ? a ^ b : ~(a ^ b);
    
    always @(*) begin
        case (ALUControl)
            4'b0000: Result = sum_extended[31:0]; // ADD
            4'b0001: Result = sum_extended[31:0]; // SUB
            4'b0010: Result = a & b; // AND
            4'b0011: Result = a | b; // OR
            4'b0100: Result = a ^ b; // XOR
            4'b0101: Result = ~(a ^ b); // XNOR
            4'b0110: Result = a << b[4:0]; // LSL
            4'b0111: Result = a >> b[4:0]; // LSR
            4'b1000: Result = a >>> b[4:0]; // ASR
            4'b1001: Result = {a[0], a[31:1]}; // ROR
            4'b1010: Result = Saturated ? saturated_sum : sum_extended[31:0]; // QADD
            4'b1011: Result = Saturated ? saturated_sub : a - b; // QSUB
            default: Result = 32'b0; // NOP
        endcase
    end

    assign ALUFlags[3] = Result[31];
    assign ALUFlags[2] = (Result == 32'b0);
    assign ALUFlags[1] = sum_extended[32];
    assign ALUFlags[0] = (a[31] == b[31]) && (a[31] != Result[31]);
endmodule
