`timescale 1ns / 100ps
`default_nettype none

module fpu (clk, rstn, funct3, funct7, x1, x2, y);
    input wire clk, rstn;
    input wire [2:0] funct3;
    input wire [6:0] funct7;
    input wire [31:0] x1, x2;
    output [31:0] y;

    wire [31:0] y;
    wire [31:0] fsgnj_s_res, fsgnjn_s_res, fsgnjx_s_res;
    wire [31:0] fsgnj_s_3_res;

    fsgnj_s   fsgnj_s_0  (x1, x2, fsgnj_s_res);
    fsgnjn_s  fsgnjn_s_0 (x1, x2, fsgnjn_s_res);
    fsgnjx_s  fsgnjx_s_0 (x1, x2, fsgnjx_s_res);

    assign fsgnj_s_3_res =
        funct3 == 3'h0 ? fsgnj_s_res
      : funct3 == 3'h1 ? fsgnjn_s_res
                       : fsgnjx_s_res;
    assign y =
        funct7 == 7'h10 ? fsgnj_s_3_res
                        : 0;
endmodule
