`timescale 1ns / 1ps

module condcheck (
	input wire [3:0] Cond,
	input wire [3:0] Flags,
	output reg CondEx
);
	wire neg;
	wire zero;
	wire carry;
	wire overflow;
	wire ge;
	
	assign {neg, zero, carry, overflow} = Flags;
	assign ge = neg == overflow;
	
	always @(*) begin
		case (Cond)
			4'b0000: CondEx = zero; // EQual
			4'b0001: CondEx = ~zero; // Not Equal
			4'b0010: CondEx = carry; // Carry Set (unsigned Higher or Same)
			4'b0011: CondEx = ~carry; // Carry Clear (unsigned LOwer)
			4'b0100: CondEx = neg; // MInus (negative)
			4'b0101: CondEx = ~neg; // PLus (positive or zero)
			4'b0110: CondEx = overflow; // V Set (signed overflow)
			4'b0111: CondEx = ~overflow; // V Clear (no signed overflow)
			4'b1000: CondEx = carry & ~zero; // unsigned HIgher
			4'b1001: CondEx = ~(carry & ~zero); // unsigned Lower or Same
			4'b1010: CondEx = ge; // signed Greater than or Equal
			4'b1011: CondEx = ~ge; // signed Less Than
			4'b1100: CondEx = ~zero & ge; // signed Greater Than
			4'b1101: CondEx = ~(~zero & ge); // signed Less than or Equal
			4'b1110: CondEx = 1'b1; // ALways
			default: CondEx = 1'bx; // Undefined
		endcase
	end
endmodule
