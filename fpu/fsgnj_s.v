`timescale 1ns / 100ps
`default_nettype none

module fsgnj_s (x1, x2, y);
    input wire [31:0] x1, x2;
    output [31:0] y;

    wire [31:0] y;

    assign y = {x2[31], x1[30:0]};    
endmodule
