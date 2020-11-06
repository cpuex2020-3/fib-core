`timescale 1ns / 100ps
`default_nettype none

module processor #(parameter MEM = 10) (clk, rstn, a0out, txd);
    input wire clk, rstn;
    output [7:0] a0out;
    output txd;

    wire we;
    wire [7:0] a0out;
    wire txd;
    wire [MEM-1:0] addr;
    wire [31:0] din;
    wire [31:0] dout;
    wire [7:0] sdata;
    wire tx_ready;

    rams_init_file rams_init_file_0(clk, we, addr, din, dout);
    uart_tx uart_tx_0(clk, rstn, sdata, tx_ready, txd);
    core core_0(clk, rstn, we, addr, din, dout, a0out, sdata, tx_ready);
endmodule
