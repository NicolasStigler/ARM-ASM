`timescale 1ns / 1ps

module pipelineit(
    input wire [31:0] i,
    output wire [31:0] o,
    input wire clk,
    input wire reset,
    input wire stall
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            o <= 0;
        else if (!stall)
            o <= i;
    end
endmodule
