`timescale 1ns / 1ps

module decode (
    Op,
    Funct,
    Rd,
    FlagW,
    PCS,
    RegW,
    MemW,
    MemtoReg,
    ALUSrc,
    ImmSrc,
    RegSrc,
    ALUControl
);
    input wire [1:0] Op; // Main opcode field
    input wire [5:0] Funct; // Secondary opcode (function field)
    input wire [3:0] Rd; // Destination register
    output reg [1:0] FlagW; // Control flags for flag updates
    output wire PCS; // Program counter source
    output wire RegW; // Register write enable
    output wire MemW; // Memory write enable
    output wire MemtoReg; // Select between ALU result and memory data
    output wire ALUSrc; // Select ALU source operand (register or immediate)
    output wire [1:0] ImmSrc; // Select type of immediate value
    output wire [1:0] RegSrc; // Source register selection control
    output reg [4:0] ALUControl; // ALU control signal
    reg [9:0] controls;
    wire Branch; // Branch enable
    wire ALUOp; // ALU operation enable

    always @(*) begin
        casex (Op)
            2'b00: // Data processing
                if (Funct[5]) // Branch instructions
                    controls = 10'b0000101001; // PCS enabled, branch
                else
                    controls = 10'b0000001001; // Standard ALU operation
            2'b01: // Load/store
                if (Funct[0]) // Store
                    controls = 10'b0001111000; // MemWrite enabled
                else // Load
                    controls = 10'b1001110100; // MemtoReg enabled
            2'b10: // Branch instructions
                controls = 10'b0110100010; // Branch logic
            default: controls = 10'bxxxxxxxxxx; // Undefined
        endcase
    end

    // Assign the decoded control signals
    assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

    always @(*) begin
        if (ALUOp) begin
            // Map `Funct` bits to ALU operations
            case (Funct[4:0])
                5'b01000: ALUControl = 5'b00000; // ADD
                5'b00100: ALUControl = 5'b00001; // SUB
                5'b01100: ALUControl = 5'b00010; // RSB
                5'b01001: ALUControl = 5'b00011; // ADC
                5'b01101: ALUControl = 5'b00100; // SBC
                5'b10000: ALUControl = 5'b00101; // AND
                5'b10100: ALUControl = 5'b00110; // ORR
                5'b11000: ALUControl = 5'b00111; // ORN
                5'b10001: ALUControl = 5'b01000; // EOR
                5'b10101: ALUControl = 5'b01001; // BIC
                5'b00001: ALUControl = 5'b01010; // LSL
                5'b00010: ALUControl = 5'b01011; // LSR
                5'b00011: ALUControl = 5'b01100; // ASR
                5'b00101: ALUControl = 5'b01101; // ROR
                5'b00110: ALUControl = 5'b01110; // CMP (Flag-only)
                5'b00111: ALUControl = 5'b01111; // TST (Flag-only)
                5'b01010: ALUControl = 5'b10000; // TEQ (Flag-only)
                5'b01011: ALUControl = 5'b10001; // CMN (Flag-only)
                default: ALUControl = 5'bxxxxx; // Undefined operation
            endcase

            // Control flags for ALU operations
            FlagW[1] = Funct[0]; // Update flags based on instruction type
            FlagW[0] = Funct[0] & ((ALUControl == 5'b00000) | (ALUControl == 5'b00001)); // Only ADD/SUB affect Z and N
        end else begin
            // Default values for non-ALU operations
            ALUControl = 5'b00000;
            FlagW = 2'b00;
        end
    end

    // Program counter source logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule
