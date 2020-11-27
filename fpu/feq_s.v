`timescale 1ns / 100ps
`default_nettype none

module feq_s (x1, x2, y);
    input wire [31:0] x1, x2;
    output [31:0] y;

    wire bothzero;
    wire [31:0] y;

    assign bothzero = (x1[30:0] == 0) & (x2[30:0] == 0);
    assign y = {31'b0, (x1 == x2) | bothzero};
endmodule
