`timescale 1ns / 1ps

module testbench();
    reg clk;
    reg reset;
    wire [31:0] WriteData;
    wire [31:0] DataAdr;
    wire MemWrite;
    
    top dut(
        .clk(clk),
        .reset(reset),
        .WriteDataM(WriteData), // Corrected signal name to match DUT
        .DataAdrM(DataAdr),     // Corrected signal name to match DUT
        .MemWriteM(MemWrite)    // Corrected signal name to match DUT
    );
    
    initial begin
        reset = 1;
        #(22); // Hold reset high for 22 time units
        reset = 0;
    end
    
    always begin
        clk = 1;
        #(5); // High for 5 time units
        clk = 0;
        #(5); // Low for 5 time units
    end
    
    always @(negedge clk) begin
        if (MemWrite) begin
            if (DataAdr === 64 && WriteData === 64) begin
                $display("Simulation succeeded!!!");
                $stop;
            end else if (DataAdr !== 96) begin
                $display("Simulation failed :c");
                $stop;
            end
        end
    end
endmodule
