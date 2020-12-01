`timescale 1ns / 100ps
`default_nettype none

module mul10 (x, y);
    input wire [31:0] x;
    output [31:0] y;

    wire [31:0] y;

    assign y = {x[28:0], 3'b0} + {x[30:0], 1'b0};
endmodule

module div10 (x, y);
    input wire [31:0] x;
    output [31:0] y;

    wire [31:0] y;
    wire [63:0] z;

    localparam multiplier = 32'hCCCCCCCC;

    assign z = x * multiplier;
    assign y = {3'b0, z[63:35]};
endmodule

module misc (a, b, control, result);
    input wire [31:0] a, b;
    input wire [2:0] control;
    output [31:0] result;

    wire [31:0] mul10res, div10res;
    wire [31:0] result;

    mul10 mul10_0(a, mul10res);
    div10 div10_0(a, div10res);
    assign result =
        control == 3'h0 ? mul10res
      : control == 3'h1 ? div10res
                        : a ^ b;
endmodule
