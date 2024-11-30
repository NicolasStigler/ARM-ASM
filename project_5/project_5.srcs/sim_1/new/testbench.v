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
        .WriteDataM(WriteData),
        .DataAdrM(DataAdr),
        .MemWriteM(MemWrite)
    );

    // Clock and reset initialization
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

    // Monitoring Memory Writes and PC
    integer cycle_count = 0; // For tracking simulation progress
    always @(negedge clk) begin
        cycle_count = cycle_count + 1;
        
        if (MemWrite) begin
            $display("Cycle %0d: Memory Write - Address: %h, Data: %h", cycle_count, DataAdr, WriteData);
        end

        // Add additional checks if needed
    end

    // End simulation after a fixed number of cycles
    initial begin
        #(1000); // Adjust this duration based on program size and expected execution time
        $display("Simulation timed out after 1000 cycles.");
        $stop;
    end
endmodule
