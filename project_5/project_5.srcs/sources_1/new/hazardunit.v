`timescale 1ns / 1ps

module hazardunit(
    input clk,
    input reset,
    input Check1_EM,
    input Check1_EW,
    input Check2_EM,
    input Check2_EW,
    input Check12_DE,
    input RegWriteM,
    input RegWriteW,
    input BranchTakenE,      // Branch taken signal from the Execute stage
    input LinkWriteE,        // Link write signal for BL (Branch with Link)
    input MemtoRegE,
    input PCWPendingF,
    input PCSrcW,
    input UpdateBaseE,       // Signal for base register update in Execute stage
    input UpdateBaseM,       // Signal for base register update in Memory stage
    output [1:0] ForwardAE, ForwardBE,
    output StallF, StallD,
    output FlushD, FlushE
);
    wire ldrStallD;
    wire baseUpdateHazard; // Hazard due to base register update
    wire branchHazard;     // Hazard due to branch instructions
    reg [1:0] ForwardAE, ForwardBE;

    // Forwarding logic
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

    // Detect hazard for load-use and base register update
    assign ldrStallD = Check12_DE & MemtoRegE;

    // Detect hazard for base register update
    assign baseUpdateHazard = UpdateBaseE | UpdateBaseM;

    // Detect hazard for branch instructions
    assign branchHazard = BranchTakenE | LinkWriteE;

    // Stall and flush logic
    assign StallF = ldrStallD | PCWPendingF | baseUpdateHazard;
    assign StallD = ldrStallD | baseUpdateHazard;
    assign FlushD = PCWPendingF | PCSrcW | BranchTakenE | LinkWriteE; // Flush if branch/link occurs
    assign FlushE = ldrStallD | BranchTakenE | LinkWriteE;            // Flush Execute stage on branch
endmodule
