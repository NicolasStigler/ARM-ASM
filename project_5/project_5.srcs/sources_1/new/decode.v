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
	output reg [2:0] ALUControl
);
	reg [9:0] controls;
	wire Branch;
	wire ALUOp;
	
	always @(*) begin
		control = 10'b0000000000;
		FlagW = 2'b00;
		case (Op)
			2'b00:
				if (Funct[5]) controls = 10'b0000101001; // DP Imm
				else controls = 10'b0000001001; // DP Reg
			2'b01:
				if (Funct[0]) controls = 10'b0001111000; // LDR
				else controls = 10'b1001110100; // STR
			2'b10: controls = 10'b0110100010; // Branch
			default: controls = 10'bxxxxxxxxxx;
		endcase
	end
	
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;
	
	always @(*) begin
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: ALUControl = 3'b000; // ADD
				4'b0010: ALUControl = 3'b001; // SUB
				4'b0000: ALUControl = 3'b010; // AND
				4'b1100: ALUControl = 3'b011; // OR
				default: ALUControl = 3'bxxx;
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001));
		end else begin
			ALUControl = 3'b000; // ADD para non-DP
			FlagW = 2'b00; // Las Flags no se actualizan
		end
	end
	
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
endmodule
