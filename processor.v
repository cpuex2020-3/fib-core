`timescale 1ns / 100ps
`default_nettype none

module processor #(parameter MEM = 19) (clk, rstn, fin, a0out, rxd, txd);
    input wire clk, rstn;
    input wire rxd;
    output fin;
    output [7:0] a0out;
    output txd;

    wire fin;
    wire we;
    wire [7:0] a0out;
    wire txd, next;
    wire [MEM-3:0] pc;
    wire [MEM-1:0] addr;
    wire [31:0] din;
    wire [31:0] instr, dout;
    wire [7:0] rdata, sdata;
    wire rx_ready, tx_ready;

    ram_prog ram_prog_0(clk, pc, instr);
    ram_data ram_data_0(clk, we, addr, din, dout);
    uart_rx_with_buf uart_rx_0(clk, rstn, rxd, next, rdata, rx_ready);
    uart_tx_with_buf uart_tx_0(clk, rstn, sdata, tx_ready, txd);
    core core_0(clk, rstn, pc, instr, fin, we, addr, din, dout, a0out, 
        rdata, rx_ready, next, sdata, tx_ready);
endmodule
