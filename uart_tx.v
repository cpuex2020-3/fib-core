`timescale 1ns / 100ps
`default_nettype none

module uart_tx #(CLK_PER_BIT = 868) (
    clk, rstn, sdata, tx_ready, txd);
    input wire clk, rstn;
    input wire [7:0] sdata;
    input wire tx_ready;
    output txd;    
    
    reg txd;
    reg [7:0] txbuf [255:0];
    reg [7:0] stack_bottom, stack_top;
    reg [3:0] status;
    reg [31:0] counter;
    
    localparam s_bit_0      = 4'h0;
    localparam s_bit_1      = 4'h1;
    localparam s_bit_2      = 4'h2;
    localparam s_bit_3      = 4'h3;
    localparam s_bit_4      = 4'h4;
    localparam s_bit_5      = 4'h5;
    localparam s_bit_6      = 4'h6;
    localparam s_bit_7      = 4'h7;
    localparam s_idle       = 4'h8;
    localparam s_start_bit  = 4'h9;
    localparam s_stop_bit   = 4'hA;

    always @(posedge clk) begin
        if (~rstn) begin
            txd <= 1;
            stack_bottom <= 0;
            stack_top <= 0;
            status <= s_idle;
            counter <= 0;
        end else begin
            // save input to buffer
            if (tx_ready) begin
                txbuf[stack_top] <= sdata;
                stack_top <= stack_top + 1;
            end

            // send output in UART
            counter <= counter == CLK_PER_BIT ? 0 : counter + 1;
            if (counter == 0 && stack_bottom != stack_top) begin
                if (status == s_idle) begin
                    status <= s_start_bit;
                    txd <= 0;
                end else if (status == s_start_bit) begin
                    status <= s_bit_0;
                    txd <= txbuf[stack_bottom][0];
                end else if (status == s_bit_0) begin
                    status <= s_bit_1;
                    txd <= txbuf[stack_bottom][1];
                end else if (status == s_bit_1) begin
                    status <= s_bit_2;
                    txd <= txbuf[stack_bottom][2];
                end else if (status == s_bit_2) begin
                    status <= s_bit_3;
                    txd <= txbuf[stack_bottom][3];
                end else if (status == s_bit_3) begin
                    status <= s_bit_4;
                    txd <= txbuf[stack_bottom][4];
                end else if (status == s_bit_4) begin
                    status <= s_bit_5;
                    txd <= txbuf[stack_bottom][5];
                end else if (status == s_bit_5) begin
                    status <= s_bit_6;
                    txd <= txbuf[stack_bottom][6];
                end else if (status == s_bit_6) begin
                    status <= s_bit_7;
                    txd <= txbuf[stack_bottom][7];
                end else if (status == s_bit_7) begin
                    status <= s_stop_bit;
                    txd <= 1;
                end else if (status == s_stop_bit) begin
                    status <= s_idle;
                    stack_bottom <= stack_bottom + 1;
                end
            end
        end
    end
endmodule
