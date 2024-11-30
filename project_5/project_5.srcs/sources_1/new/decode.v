`timescale 1ns / 1ps

module decode (
    input wire [1:0] Op,
    input wire [5:0] Funct,
    input wire [3:0] Rd,
    input wire [1:0] ShiftType,    // Shift type field (e.g., LSL, ASR, ROR)
    input wire [4:0] ShiftAmount,  // Shift amount field
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
    output reg SpecialInstr, // Signal for special instructions (Op == 11)
    output reg [4:0] SpecialInstrControl, // Control for special instructions
    output reg LoadMultiple,  // Signal for LDM instructions
    output reg StoreMultiple, // Signal for STM instructions
    output reg PreDecrement,  // Addressing mode for decrement before
    output reg PostIncrement  // Addressing mode for increment after
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
        LoadMultiple = 1'b0;
        StoreMultiple = 1'b0;
        PreDecrement = 1'b0;
        PostIncrement = 1'b0;

        case (Op)
            2'b00: begin // Data Processing
                case (Funct[4:1])
                    4'b1000: ALUControl = 5'b00000; // ADD
                    4'b0001: ALUControl = 5'b00001; // AND
                    4'b0010: ALUControl = 5'b00010; // ORR
                    4'b0011: ALUControl = 5'b00011; // EOR
                    4'b0100: ALUControl = 5'b00100; // SUB
                    4'b0101: ALUControl = 5'b00101; // RSB
                    4'b0110: ALUControl = 5'b00110; // CMP
                    4'b0111: ALUControl = 5'b00111; // TST
                    4'b1110: begin // MOV
                        case (ShiftType)
                            2'b00: ALUControl = 5'b01000; // LSL
                            2'b01: ALUControl = 5'b01001; // LSR
                            2'b10: ALUControl = 5'b01010; // ASR
                            2'b11: begin
                                if (ShiftAmount == 5'b00000)
                                    ALUControl = 5'b01011; // RRX
                                else
                                    ALUControl = 5'b01100; // ROR
                            end
                            default: ALUControl = 5'bxxxxx; // Undefined shift
                        endcase
                    end
                    default: ALUControl = 4'bxxxx; // Undefined
                endcase
                FlagW = {Funct[0], Funct[0] & ((ALUControl == 5'b00000) | (ALUControl == 5'b00100))}; // Flags
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
                    5'b10000: begin // STMIA (Store Multiple Increment After)
                        StoreMultiple = 1'b1;
                        PostIncrement = 1'b1;
                        UpdateBase = 1'b1;
                    end
                    5'b10001: begin // LDMDB (Load Multiple Decrement Before)
                        LoadMultiple = 1'b1;
                        PreDecrement = 1'b1;
                        UpdateBase = 1'b1;
                    end
                    5'b10010: begin // STMDB (Store Multiple Decrement Before)
                        StoreMultiple = 1'b1;
                        PreDecrement = 1'b1;
                        UpdateBase = 1'b1;
                    end
                    5'b10011: begin // LDMIA (Load Multiple Increment After)
                        LoadMultiple = 1'b1;
                        PostIncrement = 1'b1;
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
                        SpecialInstrControl = 5'b00001; // Corresponds to MUL
                    end
                    6'b000001: begin // MLA (Multiply-Accumulate)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b00010; // Corresponds to MLA
                    end
                    6'b000010: begin // MLS (Multiply-Subtract)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b00011; // Corresponds to MLS
                    end
                    6'b000011: begin // UMULL (Unsigned Multiply Long)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b00100; // Corresponds to UMULL
                    end
                    6'b000100: begin // UMLAL (Unsigned Multiply Accumulate Long)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b00101; // Corresponds to UMLAL
                    end
                    6'b000101: begin // SMULL (Signed Multiply Long)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b00110; // Corresponds to SMULL
                    end
                    6'b000110: begin // SMLAL (Signed Multiply Accumulate Long)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b00111; // Corresponds to SMLAL
                    end
                    6'b000111: begin // UDIV (Unsigned Division)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b01000; // Corresponds to UDIV
                    end
                    6'b001000: begin // SDIV (Signed Division)
                        SpecialInstr = 1'b1;
                        SpecialInstrControl = 5'b01001; // Corresponds to SDIV
                    end
                    default: begin // Undefined special instruction
                        SpecialInstr = 1'b0;
                        SpecialInstrControl = 5'b00000; // NOP or undefined
                    end
                endcase
            end
        endcase
    end

    // Program counter source logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule
