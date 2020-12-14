`timescale 1ns / 100ps
`default_nettype none

module test_processor;
    localparam STEP = 10;
    localparam CLKNUM = 1000000000;

    reg clk, rstn;
    wire fin;
    wire [7:0] a0out;
    wire rxd, txd;
    wire [7:0] rdata;
    wire rdata_ready, ferr;

    processor processor_0(clk, rstn, fin, a0out, rxd, txd);
    test_uart_tx_with_buf uart_tx_0(clk, rstn, rxd);
    uart_rx uart_rx_0(clk, rstn, txd, rdata, rdata_ready, ferr);

    always begin
        clk = 0; #(STEP/2);
        clk = 1; #(STEP/2);
    end

    initial begin
                   rstn = 1;
        #(STEP*5)  rstn = 0;
        #(STEP*5)  rstn = 1;
    end

    always @(posedge clk) begin
        if (rdata_ready) $write("%c", rdata);
        if (fin) $finish;
    end
endmodule
