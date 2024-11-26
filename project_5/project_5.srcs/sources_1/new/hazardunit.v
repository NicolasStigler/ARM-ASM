module hazardunit(
  input clk
  input reset,
  input Check1_EM,
  input Check1_EW,
  input Check2_EM,
  input Check2_EW,
  input Check12_DE,
  input RegWriteM,
  input RegWriteW,
  input BranchTakenE,
  input MemtoRegE,
  input PCWPendingF,
  input PCSrcW,
  output [1:0] ForwardAE, ForwardBE,
  output StallF, StallD,
  output FlushD, FlushE
);
  wire ldrStallD;
  reg [1:0] ForwardAE, ForwardBE;

  // Logica del forwarding
  always @(*) begin
    if (Check1_EM & RegWriteM) 
      ForwardAE = 2'b10;
    else if (Check1_EW & RegWriteW) 
      ForwardAE = 2'b01;
    else 
      ForwardAE = 2'b00;

    if (Check2_EM & RegWriteM) 
      ForwardBE = 2'b10;
    else if (Check2_EW & RegWriteW) 
      ForwardBE = 2'b01;
    else 
      ForwardBE = 2'b00;
  end

  // Logica para detectar hazards
  assign ldrStallD = Check12_DE & MemtoRegE;
  assign StallF = ldrStallD | PCWPendingF;
  assign StallD = ldrStallD;
  assign FlushD = PCWPendingF | PCSrcW | BranchTakenE;
  assign FlushE = ldrStallD | BranchTakenE;
endmodule
