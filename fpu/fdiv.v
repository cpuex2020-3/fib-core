`default_nettype none
`timescale 10ps / 1ps

module fdiv (
        input wire [31:0]  x1,
        input wire [31:0]  x2,
        input wire         clk,
        input wire         rstn,
        output wire [31:0] y);

    wire [31:0] x2n_inv;
    wire fmul_ovf;

    wire [7:0]  e1;
    wire [7:0]  e2;
    wire [7:0]  e3;

    wire [31:0] x1n;
    wire [31:0] x2n;

    assign e1 = x1[30:23];
    assign e2 = x2[30:23];

    assign e3 = (e2 >= 254) ? 1 : 0;

    assign x1n = {x1[31], e1-e3, x1[22:0]};
    assign x2n = {x2[31], e2-e3, x2[22:0]};


    finv u0(x2n, clk, rstn, x2n_inv);
    fmul u1(x1n, x2n_inv, y, fmul_ovf);

endmodule


`default_nettype wire
