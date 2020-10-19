`timescale 1ns / 100ps
`default_nettype none

module processor(clk, rstn, a0out);
    input wire clk, rstn;
    output [7:0] a0out;

    wire we;
    wire [7:0] a0out;
    wire [7:0] addr;
    wire [31:0] din;
    wire [31:0] dout;

    rams_init_file rams_init_file_0(clk, we, addr, din, dout);
    core core_0(clk, rstn, we, addr, din, dout, a0out);
endmodule
