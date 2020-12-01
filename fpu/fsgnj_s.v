`timescale 1ns / 100ps
`default_nettype none

module fsgnj_s (x1, x2s, y);
    input wire [31:0] x1;
    input wire x2s;
    output [31:0] y;

    wire [31:0] y;

    assign y = {x2s, x1[30:0]};    
endmodule
