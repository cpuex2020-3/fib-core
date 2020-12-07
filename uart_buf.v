`timescale 1ns / 100ps
`default_nettype none

module uart_buf #(parameter MEM = 18, DWIDTH=8) (clk, rstn, din, din_ready, next, dout, dout_ready);
    input wire clk, rstn, din_ready, next;
    input wire [7:0] din;
    output dout_ready;
    output [7:0] dout;

    wire neq;
    reg dout_ready;
    reg [1:0] state;
    reg [7:0] dout;
    reg [7:0] buffer [0:(1<<MEM)-1];
    reg [MEM-1:0] buf_top, buf_bottom;

    localparam s_wait_next  = 2'b00;
    localparam s_wait_buf   = 2'b01;
    localparam s_ready      = 2'b10;

    assign neq = buf_top != buf_bottom;

    always @(posedge clk) begin
        if (~rstn) begin
            dout <= 0;
        end else begin
            dout <= buffer[buf_bottom];
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            buf_top <= 0;
            buf_bottom <= 0;
            dout_ready <= 0;
            state <= s_wait_next;
        end else begin
            if (din_ready) begin
                buffer[buf_top] <= din;
                buf_top <= buf_top + 1;
            end
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
