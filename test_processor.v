`timescale 1ns / 100ps
`default_nettype none

module test_processor;
    localparam STEP = 10;
    localparam CLKNUM = 1000000000;

    reg clk, rstn;
    wire [7:0] a0out;
    wire rxd, txd;
    reg tx_ready;
    reg [7:0] sdata;

    processor processor_0(clk, rstn, a0out, rxd, txd);
    uart_tx_with_buf uart_tx_0(clk, rstn, sdata, tx_ready, rxd);

    always begin
        clk = 0; #(STEP/2);
        clk = 1; #(STEP/2);
    end

    always begin
        #(STEP*15000) sdata = sdata + 1;
                      tx_ready = 1;
        #(STEP)       tx_ready = 0;
    end

    initial begin
                   sdata = 0;
                   tx_ready = 0;
                   rstn = 1;
        #(STEP*5)  rstn = 0;
        #(STEP*5)  rstn = 1;
        #(STEP*CLKNUM);
        
        $display("a0: %x\n", a0out);
        $finish;
    end
endmodule
