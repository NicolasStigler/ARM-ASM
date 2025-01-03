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
    input LoadMultipleE,     // Signal for LDM instructions
    input StoreMultipleE,    // Signal for STM instructions
    input SpecialInstrE,     // Special instruction signal in Execute stage
    input SpecialInstrM,     // Special instruction signal in Memory stage
    output reg [1:0] ForwardAE, ForwardBE,
    output StallF,
    output StallD,
    output FlushD,
    output FlushE
);
    wire ldrStallD;
    wire baseUpdateHazard;   // Hazard due to base register update
    wire branchHazard;       // Hazard due to branch instructions
    wire specialInstrStall;  // Hazard due to special instruction dependency
    wire loadStoreMultipleHazard; // Hazard for LDM/STM instructions

    // Forwarding logic
    always @(*) begin
        if (Check1_EM & RegWriteM) 
            ForwardAE = 2'b10; // Forward from Memory stage
        else if (Check1_EW & RegWriteW) 
            ForwardAE = 2'b01; // Forward from Writeback stage
        else 
            ForwardAE = 2'b00; // No forwarding

        if (Check2_EM & RegWriteM) 
            ForwardBE = 2'b10; // Forward from Memory stage
        else if (Check2_EW & RegWriteW) 
            ForwardBE = 2'b01; // Forward from Writeback stage
        else 
            ForwardBE = 2'b00; // No forwarding
    end

    // Detect hazard for load-use (LDR)
    assign ldrStallD = Check12_DE & MemtoRegE;

    // Detect hazard for base register update
    assign baseUpdateHazard = UpdateBaseE | UpdateBaseM;

    // Detect hazard for branch instructions
    assign branchHazard = BranchTakenE | LinkWriteE;

    // Detect hazard for special instructions
    assign specialInstrStall = SpecialInstrE & (Check1_EM | Check2_EM);

    // Detect hazard for load/store multiple instructions
    assign loadStoreMultipleHazard = (LoadMultipleE | StoreMultipleE) & (baseUpdateHazard | ldrStallD);

    // Stall and flush logic
    assign StallF = ldrStallD | PCWPendingF | baseUpdateHazard | specialInstrStall | loadStoreMultipleHazard;
    assign StallD = ldrStallD | baseUpdateHazard | specialInstrStall | loadStoreMultipleHazard;
    assign FlushD = PCWPendingF | PCSrcW | branchHazard; // Flush if branch or link occurs
    assign FlushE = ldrStallD | branchHazard | specialInstrStall | loadStoreMultipleHazard; // Flush Execute stage on branch, link, or special instruction
endmodule
