`timescale 1ns / 1ps

module dmem (
	input clk,
	input we,
	input [31:0] adr,
	input [31:0] wd,
	output [31:0] rd
);
	reg [31:0] RAM[0:256];

	initial begin
		$readmemh("memfile.dat", RAM);
	end
	
	assign rd = RAM[adr[12:2]];
	
	always @(posedge clk) begin
		if (we)
			RAM[adr[12:2]] <= wd;
	end
endmodule
