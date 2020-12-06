`timescale 1ns / 100ps
`default_nettype none

module fcvt_s_w(clk, rstn, x, y);
    input wire clk, rstn;
    input wire [31:0] x;
    output [31:0] y;

    wire [22:0] x_small, x_large;
    wire [31:0] y_small, y_large;
    wire [31:0] y;
    wire isneg;
    
    assign isneg = x[31];
    assign x_small = x[22:0];
    assign x_large = {{15{x[31]}}, x[30:23]};
    itof_small itof_small_0(clk, rstn, x_small, y_small, 1'b0);
    itof_large itof_large_0(clk, rstn, x_large, y_large, isneg);
    fadd_p2 fadd_0(y_small, y_large, y, clk, rstn);
endmodule

module itof_small(clk, rstn, x, y, isneg);
    input wire clk, rstn, isneg;
    input wire [22:0] x;
    output [31:0] y;

    wire [31:0] y, a, b;

    localparam c23 = 9'h96;
    localparam c24 = 9'h97;

    assign a = {c23, x};
    assign b = {(isneg ? c24 : c23), 23'h0};
    fsub_p2 fsub_0(a, b, y, clk, rstn);
endmodule

module itof_large(clk, rstn, x, y, isneg);
    input wire clk, rstn, isneg;
    input wire [22:0] x;
    output [31:0] y;

    wire [31:0] y;
    wire [31:0] x_itof;

    itof_small itof_small_0(clk, rstn, x, x_itof, isneg);
    assign y = {1'b0, x_itof[30:23] + 8'd23, x_itof[22:0]};
endmodule
