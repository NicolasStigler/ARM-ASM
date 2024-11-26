`timescale 1ns / 1ps

module imem (
	input [31:0] adr,
	output [31:0] rd
);
	reg [31:0] RAM[0:256]; // x4 ⇒ 1024 bytes de ram
	
	initial begin
		$readmemh("memfile.dat", RAM);
	end
	
	assign rd = RAM[adr[12:2]];
endmodule
