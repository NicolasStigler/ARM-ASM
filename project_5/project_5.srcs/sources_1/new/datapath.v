`timescale 1ns / 1ps

module datapath (
	clk,
	reset,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemtoReg,
	PCSrc,
	ALUFlags,
	PC,
	InstrF,
	ALUResultM,
	WriteDataM,
	ReadData
);
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrc;
	input wire RegWrite;
	input wire [1:0] ImmSrc;
	input wire ALUSrc;
	input wire [1:0] ALUControl;
	input wire MemtoReg;
	input wire PCSrc;
	output wire [3:0] ALUFlags;
	output wire [31:0] PC;
	input wire [31:0] InstrF;
	wire [31:0] InstrD;
	wire [31:0] ALUResultE;
	output wire [31:0] ALUResultM;
	output wire [31:0] WriteDataM;
	wire [31:0] WriteData;
	input wire [31:0] ReadData;

	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] ResultW;
	wire [3:0] RA1;
	wire [3:0] RA2;

	wire [110:0] OutDecode;
	wire [110:0] InExecute;
	wire [31:0] SrcAE;
	wire [31:0] SrcBE;
	wire [31:0] ExtImmE;
	wire [31:0] WriteDataE;
	wire [3:0] WA3E;
	wire [31:0] ALUResultE;
	
	wire [110:0] OutExecute;
	wire [110:0] InMemory;
	
	wire [110:0] OutMemory;
	wire [110:0] InWB;

	pipelineit #(32) FetchToDecode(
		.i(InstrF),
		.o(InstrF),
		.clk(clk)
	);

	assign OutDecode[31:0] = SrcA;
	assign OutDecode[63:32] = WriteData;
	assign OutDecode[95:64] = ExtImm;
	assign OutDecode[99:96] = InstrD[15:12];

	pipelineit #(100) DecodeToExecute(
	       .i(OutDecode),
	       .o(InExecute),
	       .clk(clk)
	);
	
	assign SrcAE = InExecute[31:0];
	assign WriteDataE = InExecute[63:32];
	assign ExtImmE = InExecute[95:64];
	assign WA3E = InExecute[99:96];

	assign OutExecute[31:0] = ALUResultE;
	assign OutExecute[63:32] = WriteDataE;
	assign OutExecute[67:64] = InExecute[99:96];
	
	pipelineit # (110) ExecuteToMemory(
	   	.i(OutExecute),
	   	.o(InMemory),
	   	.clk(clk)
	);
	
	assign ALUResultM = InMemory[31:0];
	assign WriteDataM = InMemory[63:32];
	
	assign OutMemory[31:0] = ReadData;
	assign OutMemory[63:32] = ALUResultM;
	assign OutMemory[67:64] = InMemory[67:64];
	
	pipelineit # (110) MemoryToWriteBack (
		.i(OutMemory),
		.o(InWB),
	   	.clk(clk)
	);
	
	mux2 #(32) pcmux(
		.d0(PCPlus4),
		.d1(ResultW),
		.s(PCSrc),
		.y(PCNext)
	);

	flopr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.d(PCNext),
		.q(PC)
	);

	adder #(32) pcadd1(
		.a(PC),
		.b(32'b100),
		.y(PCPlus8)
	);

	adder #(32) pcadd2(
		.a(PCPlus4),
		.b(32'b100),
		.y(PCPlus8)
	);

	mux2 #(4) ra1mux(
		.d0(Instr[19:16]),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);
	mux2 #(4) ra2mux(
		.d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);

	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(InWB[67:64]),
		.wd3(ResultW),
		.r15(PCPlus8),
		.rd1(SrcA),
		.rd2(WriteData)
	);

	mux2 #(32) resmux(
		.d0(InWB[63:32]),
		.d1(InWB[31:0]),
		.s(MemtoReg),
		.y(ResultW)
	);

	extend ext(
		.Instr(InstrD[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);

	mux2 #(32) srcbmux(
		.d0(WriteDataE),
		.d1(ExtImmE),
		.s(ALUSrc),
		.y(SrcBE)
	);

	alu alu(
		SrcAE,
		SrcBE,
		ALUControl,
		ALUResultE,
		ALUFlags
	);
endmodule

