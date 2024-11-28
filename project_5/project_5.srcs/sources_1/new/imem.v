`timescale 1ns / 1ps

module imem (
	input [31:0] adr,
	output [31:0] rd
);
	reg [31:0] RAM [63:0];
	
	initial begin
		$readmemh("memfile.dat", RAM);
	end
	
	assign rd = RAM[adr[31:2]];
endmodule
