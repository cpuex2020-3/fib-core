`timescale 1ns / 100ps
`default_nettype none

module test_processor;
    localparam STEP = 10;
    localparam CLKNUM = 1000000000;

    reg clk, rstn;
    wire [7:0] a0out;
    wire txd;

    processor processor_0(clk, rstn, a0out, txd);

    always begin
        clk = 0; #(STEP/2);
        clk = 1; #(STEP/2);
    end

    initial begin
                   rstn = 1;
        #(STEP*5)  rstn = 0;
        #(STEP*5)  rstn = 1;
        #(STEP*CLKNUM);
        
        $display("a0: %x\n", a0out);
        $finish;
    end
endmodule
