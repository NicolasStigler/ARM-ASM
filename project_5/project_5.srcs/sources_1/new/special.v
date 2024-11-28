`timescale 1ns / 1ps

module special (
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    input [63:0] accum,    // For accumulate/long operations
    input [4:0] SpecialInstrControl, // Control signal for special operations
    output reg [63:0] result, // Extended result for long operations
    output reg [3:0] flags    // Flags: N (Negative), Z (Zero), C (Carry), V (Overflow)
);
    always @(*) begin
        case (SpecialInstrControl)
            5'b00001: result = a * b; // MUL
            5'b00010: result = a * b + accum[31:0]; // MLA
            5'b00011: result = accum[31:0] - (a * b); // MLS
            5'b00100: result = a * b; // UMULL
            5'b00101: result = a * b + accum; // UMLAL
            5'b00110: result = $signed(a) * $signed(b); // SMULL
            5'b00111: result = $signed(a) * $signed(b) + $signed(accum); // SMLAL
            5'b01000: result = a / b; // UDIV
            5'b01001: result = $signed(a) / $signed(b); // SDIV
            default: result = 64'b0; // NOP for undefined instructions
        endcase

        // Update flags
        flags[3] = result[31]; // N (Negative)
        flags[2] = (result == 0); // Z (Zero)
        flags[1] = 0; // C (Carry): Not applicable for multiplication/division
        flags[0] = 0; // V (Overflow): Simplified, needs saturation logic for exact cases
    end
endmodule
