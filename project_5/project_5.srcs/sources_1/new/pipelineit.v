`timescale 1ns / 1ps

module pipelineit(
    input wire  i,
    output wire o,
    input wire clk
);
    reg next;
    always @ (posedge clk) 
        next <= i;
        
    assign o = next;

endmodule
