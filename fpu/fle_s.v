`timescale 1ns / 100ps
`default_nettype none

module fle_s (x1, x2, y);
    input wire [31:0] x1, x2;
    output [31:0] y;

    wire bothzero;
    wire le;
    wire y_;
    wire [31:0] y;

    assign bothzero = (x1[30:0] == 0) & (x2[30:0] == 0);
    assign le = x1[30:0] <= x2[30:0];
    assign ge = x1[30:0] >= x2[30:0];
    assign y_ =
        x1[31] == 1'b0 && x2[31] == 1'b0 ? le
      : x1[31] == 1'b0 && x2[31] == 1'b1 ? bothzero
      : x1[31] == 1'b1 && x2[31] == 1'b0 ? 1
                                         : ge;
    assign y = {31'b0, y_};
endmodule
