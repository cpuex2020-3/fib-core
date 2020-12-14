`timescale 1ns / 100ps
`default_nettype none

module fpu (clk, rstn, funct3, funct7, x1, x2, y);
    input wire clk, rstn;
    input wire [2:0] funct3;
    input wire [6:0] funct7;
    input wire [31:0] x1, x2;
    output [31:0] y;

    wire [31:0] y;
    wire [31:0] fadd_s_res;
    wire [31:0] fsub_s_res;
    wire [31:0] fmul_s_res;
    wire [31:0] fdiv_s_res;
    wire [31:0] fsgnj_s_res, fsgnjn_s_res, fsgnjx_s_res;
    wire [31:0] fsqrt_s_res;
    wire [31:0] feq_s_res, flt_s_res, fle_s_res;
    wire [31:0] fcvt_s_w_res;
    wire [31:0] fmv_w_s_res;
    wire [31:0] fmv_s_w_res;
    wire [31:0] fsgnj_s_3_res, fcompare_s_3_res;

    fadd_p2   fadd_0     (x1, x2, fadd_s_res, clk, rstn);
    fsub_p2   fsub_0     (x1, x2, fsub_s_res, clk, rstn);
    fmul      fmul_0     (x1, x2, fmul_s_res);
    fdiv      fdiv_0     (x1, x2, clk, rstn, fdiv_s_res);
    fsgnj_s   fsgnj_s_0  (x1, x2[31], fsgnj_s_res);
    fsgnjn_s  fsgnjn_s_0 (x1, x2[31], fsgnjn_s_res);
    fsgnjx_s  fsgnjx_s_0 (x1, x2[31], fsgnjx_s_res);
    fsqrt     fsqrt_s_0  (x1, clk, rstn, fsqrt_s_res);
    feq_s     feq_s_0    (x1, x2, feq_s_res);
    flt_s     flt_s_0    (x1, x2, flt_s_res);
    fle_s     fle_s_0    (x1, x2, fle_s_res);
    fcvt_s_w  fcvt_s_w_0 (clk, rstn, x1, fcvt_s_w_res);
    fmv_w_s   fmv_w_s_0  (x1, fmv_w_s_res);
    fmv_s_w   fmv_s_w_0  (x1, fmv_s_w_res);

    assign fsgnj_s_3_res =
        funct3 == 3'h0 ? fsgnj_s_res
      : funct3 == 3'h1 ? fsgnjn_s_res
                       : fsgnjx_s_res;
    assign fcompare_s_3_res =
        funct3 == 3'h2 ? feq_s_res
      : funct3 == 3'h1 ? flt_s_res
                       : fle_s_res;
    assign y =
        funct7 == 7'h00 ? fadd_s_res
      : funct7 == 7'h04 ? fsub_s_res
      : funct7 == 7'h08 ? fmul_s_res
      : funct7 == 7'h0C ? fdiv_s_res
      : funct7 == 7'h10 ? fsgnj_s_3_res
      : funct7 == 7'h2C ? fsqrt_s_res
      : funct7 == 7'h50 ? fcompare_s_3_res
      : funct7 == 7'h68 ? fcvt_s_w_res
      : funct7 == 7'h70 ? fmv_w_s_res
      : funct7 == 7'h78 ? fmv_s_w_res
                        : x1 ^ x2;
endmodule
