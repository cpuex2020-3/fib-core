`timescale 1ns / 100ps
`default_nettype none

module test_uart_buf #(parameter MEM = 18, DWIDTH=8) (clk, rstn, next, dout, dout_ready);
    input wire clk, rstn, next;
    output dout_ready;
    output [7:0] dout;

    wire neq;
    reg dout_ready;
    reg [1:0] state;
    reg [7:0] dout;
    reg [7:0] buffer [0:(1<<MEM)-1];
    reg [MEM-1:0] buf_top, buf_bottom;
    reg go;

    localparam STEP = 10;

    localparam s_wait_next  = 2'b00;
    localparam s_wait_buf   = 2'b01;
    localparam s_ready      = 2'b10;

    assign neq = buf_top != buf_bottom;

    initial begin
                        go = 0;
        #(STEP * 10000) $readmemh("contest.hex", buffer);
                        go = 1;
    end

    always @(posedge clk) begin
        if (~rstn) begin
            dout <= 0;
        end else begin
            dout <= buffer[buf_bottom];
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            buf_top <= 18'd1300;
            buf_bottom <= 0;
            dout_ready <= 0;
            state <= s_wait_next;
        end else if (go) begin
            if (state == s_wait_next) begin
                if (next) begin
                    if (neq) begin
                        state <= s_ready;
                        dout_ready <= 1;
                    end else begin
                        state <= s_wait_buf;
                    end
                end
            end else if (state == s_wait_buf) begin
                if (neq) begin
                    state <= s_ready;
                    dout_ready <= 1;                    
                end
            end else if (state == s_ready) begin
                state <= s_wait_next;
                dout_ready <= 0;
                buf_bottom <= buf_bottom + 1;
            end else begin
                state <= s_wait_next;
            end
        end
    end
endmodule

module test_uart_tx_with_buf (clk, rstn, txd);
    input wire clk, rstn;

    output txd;

    wire txd;
    wire next, dout_ready;
    wire [7:0] dout;

    test_uart_buf uart_buf_0(clk, rstn, next, dout, dout_ready);
    uart_tx uart_tx_0(clk, rstn, dout, dout_ready, txd, next);
endmodule
