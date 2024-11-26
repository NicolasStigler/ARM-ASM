`timescale 1ns / 1ps

module alu (
    input signed [31:0] a, b,
    input [4:0] ALUControl,
    input Saturated,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags // Negative, Zero, Carry, oVerflow
);
    wire [31:0] condinvb;
    wire [32:0] sum_extended;
    wire [31:0] logic_result;
    wire signed [31:0] saturated_sum;
    wire signed [31:0] saturated_sub;

    reg [31:0] temp; // Temporary register for flag-only instructions
    wire carry_out;  // Carry out for addition and subtraction

    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum_extended = {1'b0, a} + {1'b0, condinvb} + ALUControl[0]; // {1'b0, num}: num -> 0num
    assign saturated_sum = (sum_extended[31] == 1'b0 && sum_extended[30:0] > $signed(32'b01111111111111111111111111111111)) ? 32'b01111111111111111111111111111111 : (sum_extended[31] == 1'b1 && sum_extended[30:0] < $signed(32'h10000000000000000000000000000000)) ? 32'h10000000000000000000000000000000 : sum_extended[31:0];
    assign saturated_sub = (a > 0 && b < 0 && a - b < 0) ? 32'b01111111111111111111111111111111 : (a < 0 && b > 0 && a - b > 0) ? 32'h10000000000000000000000000000000 : a - b;
    assign logic_result = (ALUControl[1:0] == 2'b00) ? a & b : (ALUControl[1:0] == 2'b01) ? a | b : (ALUControl[1:0] == 2'b10) ? a ^ b : ~(a ^ b);
    
    always @(*) begin
    case (ALUControl)
        5'b00000: Result = a + b; // ADD
        5'b00001: Result = a - b; // SUB
        5'b00010: Result = b - a; // RSB (Reverse Subtract)
        5'b00011: Result = a + b + ALUFlags[1]; // ADC (Add with Carry)
        5'b00100: Result = a - b - ~ALUFlags[1]; // SBC (Subtract with Carry)
        5'b00101: Result = a & b; // AND
        5'b00110: Result = a | b; // ORR
        5'b00111: Result = a | ~b; // ORN (Logical OR NOT)
        5'b01000: Result = a ^ b; // EOR
        5'b01001: Result = a & ~b; // BIC (Bit Clear)
        5'b01010: Result = a << b[4:0]; // LSL (Logical Shift Left)
        5'b01011: Result = a >> b[4:0]; // LSR (Logical Shift Right)
        5'b01100: Result = a >>> b[4:0]; // ASR (Arithmetic Shift Right)
        5'b01101: Result = {a[0], a[31:1]}; // ROR (Rotate Right

        // Flag-only instructions
        5'b01110: begin // CMP
            temp = a - b;
            Result = 32'b0; // CMP doesn't write output
        end
        5'b01111: begin // TST
            temp = a & b;
            Result = 32'b0; // TST doesn't write output
        end
        5'b10000: begin // TEQ
            temp = a ^ b;
            Result = 32'b0; // TEQ doesn't write output
        end
        5'b10001: begin // CMN
            temp = a + b;
            Result = 32'b0; // CMN doesn't write output
        end

        default: Result = 32'b0; // NOP
    endcase
end

    assign ALUFlags[3] = temp[31]; // N (Negative)
assign ALUFlags[2] = (temp == 0); // Z (Zero)
assign ALUFlags[1] = (ALUControl == 5'b00000 || ALUControl == 5'b10000) ? sum_extended[32] : carry_out; // C (Carry)
assign ALUFlags[0] = (a[31] == b[31]) && (a[31] != temp[31]); // V (Overflow)
endmodule