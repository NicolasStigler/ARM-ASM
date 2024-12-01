`timescale 1ns / 1ps

module dmem (
	input wire clk,
	input wire we,
	input wire [31:0] adr,
	input wire [31:0] wd,
	output wire [31:0] rd
);
	reg [31:0] RAM[63:0];

	initial begin
		$readmemh("memfile.dat", RAM);
	end
	
	assign rd = RAM[adr[12:2]];
	
	always @(posedge clk) begin
		if (we)
			RAM[adr[31:2]] <= wd;
	end
endmodule
