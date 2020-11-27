`timescale 1ns / 100ps
`default_nettype none

module fabs (x, y);
    input wire [31:0] x;
    output [31:0] y;

    reg [31:0] y;

    assign y = {1'b0, x[30:0]};    
endmodule
