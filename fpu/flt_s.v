`timescale 1ns / 100ps
`default_nettype none

module flt_s (x1, x2, y);
    input wire [31:0] x1, x2;
    output [31:0] y;

    wire bothzero;
    wire lt, gt;
    wire y_;
    wire [31:0] y;

    assign bothzero = (x1[30:0] == 0) & (x2[30:0] == 0);
    assign lt = x1[30:0] < x2[30:0];
    assign gt = x1[30:0] > x2[30:0];
    assign y_ =
        x1[31] == 1'b0 && x2[31] == 1'b0 ? lt
      : x1[31] == 1'b0 && x2[31] == 1'b1 ? 0
      : x1[31] == 1'b1 && x2[31] == 1'b0 ? !bothzero
                                         : gt;
    assign y = {31'b0, y_};
endmodule
