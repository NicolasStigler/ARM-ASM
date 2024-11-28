`timescale 1ns / 1ps

module decode (
    input wire [1:0] Op,
    input wire [5:0] Funct,
    input wire [3:0] Rd,
    output reg [1:0] FlagW,
    output wire PCS,
    output wire RegW,
    output wire MemW,
    output wire MemtoReg,
    output wire ALUSrc,
    output wire [1:0] ImmSrc,
    output wire [1:0] RegSrc,
    output reg [4:0] ALUControl,
    output reg UpdateBase, // Signal to update the base register (Rn)
    output reg LinkWrite,  // Signal to write to the link register (R14)
    output reg SpecialInstr // Signal for special instructions (Op == 11)
);
    reg [9:0] controls;
    wire Branch; // Branch enable
    wire ALUOp;  // ALU operation enable

    always @(*) begin
        case (Op)
            2'b00: // Data Processing Instructions
                controls = 10'b0000001001; // Standard ALU operation
            2'b01: // Load/Store Instructions
                if (Funct[0]) // STR (Store)
                    controls = 10'b0001111000; // MemWrite enabled
                else // LDR (Load)
                    controls = 10'b1001110100; // MemtoReg enabled
            2'b10: // Branch Instructions
                controls = 10'b0110100010; // Branch logic
            2'b11: // Special Instructions Category
                controls = 10'b0000001000; // Custom control for special instructions
            default: controls = 10'bxxxxxxxxxx; // Undefined
        endcase
    end

    // Assign the decoded control signals
    assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

    always @(*) begin
        // Default values
        ALUControl = 5'b00000;
        UpdateBase = 1'b0;
        LinkWrite = 1'b0;
        SpecialInstr = 1'b0;

        case (Op)
            2'b00: begin // Data Processing
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
                    5'b11100: ALUControl = 5'b01110; // MOV
                    5'b11100: ALUControl = 5'b01111; // RRX (Rotate Right with Extend)
                    5'b11001: ALUControl = 5'b10000; // QADD (Saturating Add)
                    5'b11010: ALUControl = 5'b10001; // QSUB (Saturating Subtract)
                    default: ALUControl = 5'bxxxxx; // Undefined
                endcase
                FlagW = {Funct[0], Funct[0] & ((ALUControl == 5'b00000) | (ALUControl == 5'b00001))}; // Flags
            end

            2'b01: begin // Load/Store
                case (Funct[4:0])
                    5'b01100: begin // Pre-indexed mode
                        ALUControl = 5'b10010; // Pre-indexed (Rn + offset)
                        UpdateBase = 1'b0;
                    end
                    5'b01101: begin // Post-indexed mode
                        ALUControl = 5'b10011; // Post-indexed (Rn)
                        UpdateBase = 1'b1;
                    end
                endcase
            end

            2'b10: begin // Branch
                case (Funct[4:0])
                    5'b11000: begin // B (Branch)
                        ALUControl = 5'bxxxxx; // No ALU operation needed
                        LinkWrite = 1'b0; // No link register write
                    end
                    5'b11001: begin // BL (Branch with Link)
                        ALUControl = 5'bxxxxx; // No ALU operation needed
                        LinkWrite = 1'b1; // Write return address to R14
                    end
                    5'b11010: begin // CBZ (Compare and Branch if Zero)
                        ALUControl = 5'b10111; // CBZ ALU operation
                        LinkWrite = 1'b0;
                    end
                    5'b11011: begin // CBNZ (Compare and Branch if Not Zero)
                        ALUControl = 5'b11000; // CBNZ ALU operation
                        LinkWrite = 1'b0;
                    end
                endcase
            end

            2'b11: begin // Special Instructions Category
                case (Funct[5:0])
                    6'b000000: begin // MUL (Multiply)
                        SpecialInstr = 1'b1; 
                        ALUControl = 5'bxxxxx; // Pass to special hardware
                    end
                    // Other special instructions handled similarly
                    default: begin // Undefined special instruction
                        SpecialInstr = 1'b0; 
                        ALUControl = 5'bxxxxx; // Undefined control
                    end
                endcase
            end
        endcase
    end

    // Program counter source logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule  
