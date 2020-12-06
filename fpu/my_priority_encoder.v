`default_nettype none
`timescale 10ps / 1ps

module my_priority_encoder (
        input wire [26:0] myd,
        output wire [4:0] se);
    
    assign se =
        myd[25] ? 5'd0 :
        myd[24] ? 5'd1 :
        myd[23] ? 5'd2 :
        myd[22] ? 5'd3 :
        myd[21] ? 5'd4 :
        myd[20] ? 5'd5 :
        myd[19] ? 5'd6 :
        myd[18] ? 5'd7 :
        myd[17] ? 5'd8 :
        myd[16] ? 5'd9 :
        myd[15] ? 5'd10 :
        myd[14] ? 5'd11 :
        myd[13] ? 5'd12 :
        myd[12] ? 5'd13 :
        myd[11] ? 5'd14 :
        myd[10] ? 5'd15 :
        myd[9] ? 5'd16 :
        myd[8] ? 5'd17 :
        myd[7] ? 5'd18 :
        myd[6] ? 5'd19 :
        myd[5] ? 5'd20 :
        myd[4] ? 5'd21 :
        myd[3] ? 5'd22 :
        myd[2] ? 5'd23 :
        myd[1] ? 5'd24 :
        myd[0] ? 5'd25 : 5'd26;
endmodule
