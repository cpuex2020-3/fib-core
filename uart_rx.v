`timescale 1ns / 100ps
`default_nettype none

module uart_rx #(CLK_PER_BIT = 868) (
    clk, rstn, rxd, rdata, rdata_ready, ferr);
    input wire  clk, rstn, rxd;
    output [7:0] rdata;
    output rdata_ready, ferr;

    reg [7:0] rdata;
    reg rdata_ready;
    wire ferr;
    reg [31:0] counter;
    reg [31:0] counter_start;
    (* ASYNC_REG = "true" *) reg [3:0] sync_reg;
    reg [2:0] stable;
    (* mark_debug = "true" *)reg rxd_stable;
    reg [3:0] status;
    reg ce;
    reg err;

    localparam e_clk_half_bit = (CLK_PER_BIT >> 1) - 1;
    localparam e_clk_bit = CLK_PER_BIT - 1;

    localparam s_bit_0 = 0;
    localparam s_bit_1 = 1;
    localparam s_bit_2 = 2;
    localparam s_bit_3 = 3;
    localparam s_bit_4 = 4;
    localparam s_bit_5 = 5;
    localparam s_bit_6 = 6;
    localparam s_bit_7 = 7;
    localparam s_stop_bit = 8;
    localparam s_idle = 9;
    localparam s_start_bit = 10;

    assign ferr = err;

    always @(posedge clk) begin
        if (~rstn) begin
            rdata <= 0;
            rdata_ready <= 0;
            err <= 0;
            counter <= 0;
            counter_start <= 0;
            sync_reg <= 0;
            stable <= 0;
            rxd_stable <= 0;
            status <= s_idle;
            ce <= 0;
        end else if (~err) begin
            // チャタリング除去
            sync_reg <= {rxd, sync_reg[3:1]};
            if (sync_reg[0] != sync_reg[1]) begin
                stable <= 3'b0;
            end else begin
                stable <= stable + 3'b1;
            end
            if (stable == 3'b111) begin
                rxd_stable <= sync_reg[0];
            end

            // カウンタ周辺設定
            if (~rxd_stable) begin
                counter_start <= counter_start + 1;
            end else begin
                counter_start <= 0;
            end
            if (ce) begin
                if (counter == e_clk_bit) begin
                counter <= 0;
                // 処理
                if (~status[3]) begin
                    status <= status + 4'b1;
                    rdata <= {rxd_stable, rdata[7:1]};
                end else if (status == s_stop_bit) begin
                    if (~rxd_stable) begin
                        err <= 1'b1;
                    end else begin
                        rdata_ready <= 1'b1;
                    end
                    status <= s_idle;
                    ce <= 1'b0;
                end
                end else begin
                counter <= counter + 1;
                end
            end else if (counter_start == e_clk_half_bit) begin
                ce <= 1'b1;
                status <= s_bit_0;
            end else begin
                rdata_ready <= 1'b0;
            end
        end
    end
    
    endmodule

module uart_rx_with_buf (clk, rstn, rxd, next, rdata, rx_ready);
    input wire clk, rstn, rxd, next;
    output rx_ready;
    output [7:0] rdata;

    wire ferr, din_ready, rx_ready;
    wire [7:0] din, rdata;

    uart_buf uart_buf_0(clk, rstn, din, din_ready, next, rdata, rx_ready);
    uart_rx uart_rx_0(clk, rstn, rxd, din, din_ready, ferr);
endmodule
