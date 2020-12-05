`default_nettype none
`timescale 10ps / 1ps

module priority_encoder (
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

module fadd (
        input wire [31:0] x1,
        input wire [31:0] x2,
        output wire [31:0] y,
        output wire ovf);

    // step 1    
    wire s1;
    wire [7:0] e1;
    wire [22:0] m1;
    wire s2;
    wire [7:0] e2;
    wire [22:0] m2;
    // step 2
    wire [24:0] m1a;
    wire [24:0] m2a;
    // step 3
    wire [7:0] e1a;
    wire [7:0] e2a;
    // step 4
    wire [7:0] e2ai;
    // step 5
    wire [8:0] te;
    // step 6
    wire [8:0] tde_tmp [0:1];
    wire ce;
    wire [7:0] tde;
    // step 7
    wire [4:0] de;
    // step 8
    wire sel;
    // step 9
    wire [24:0] ms;
    wire [24:0] mi;
    wire [7:0] es;
    wire [7:0] ei;
    wire ss;
    // step 10
    wire [55:0] mie;
    // step 11
    wire [55:0] mia;
    // step 12
    wire tstck;
    // step 13
    wire [26:0] mye;
    // step 14
    wire [7:0] esi;
    // step 15
    wire [7:0] eyd;
    wire [26:0] myd;
    wire stck;
    // step 16
    wire [4:0] se;
    // step 17
    wire [8:0] eyf;
    // step 18
    wire [7:0] eyr;
    wire [26:0] myf;
    // step 19
    wire [24:0] myr;
    // step 20
    wire [7:0] eyri;
    // step 21
    wire [7:0] ey;
    wire [22:0] my;
    // step 22
    wire sy;
    // step 23
    wire nzm1;
    wire nzm2;

    // step 1
    assign s1 = x1[31];
    assign e1 = x1[30:23];
    assign m1 = x1[22:0];
    assign s2 = x2[31];
    assign e2 = x2[30:23];
    assign m2 = x2[22:0];
    // step 2
    assign m1a = {1'b0,(e1 != 0),m1};
    assign m2a = {1'b0,(e2 != 0),m2};
    // step 3
    assign e1a = (e1 != 0) ? e1 : 8'h01;
    assign e2a = (e2 != 0) ? e2 : 8'h01;
    // step 4
    assign e2ai = ~e2a;
    // step 5
    assign te = {1'b0,e1a} + {1'b0,e2ai};
    // step 6
    assign ce = ! te[8];
    assign tde_tmp[0] = te + 9'b1;
    assign tde_tmp[1] = ~te;
    assign tde = tde_tmp[ce][7:0];
    // step 7
    assign de = (tde[7:5] != 0) ? 5'h1F : tde[4:0];
    // step 8
    assign sel = (de != 0) ? ce : ! (m1a > m2a);
    // step 9
    assign ms = sel ? m2a : m1a;
    assign mi = sel ? m1a : m2a;
    assign es = sel ? e2a : e1a;
    assign ei = sel ? e1a : e2a;
    assign ss = sel ? s2 : s1;
    // step 10
    assign mie = {mi, 31'b0};
    // step 11
    assign mia = mie >> de;
    // step 12
    assign tstck = (mia[28:0] != 0);
    // step 13
    assign mye = (s1 == s2) ? {ms,2'b0} + mia[55:29] : {ms,2'b0} - mia[55:29];
    // step 14
    assign esi = es + 8'b1;
    // step 15
    assign eyd = mye[26] ? esi : es;
    assign myd = mye[26] ? ((& esi) ? {2'b01,25'b0} : mye >> 1) : mye;
    assign stck = mye[26] ? (!(& esi) & (tstck | mye[0])) : tstck;
    // step 16
    priority_encoder pe(myd, se);
    // step 17
    assign eyf = {1'b0,eyd} - {4'b0,se};
    // step 18
    assign myf = ((!eyf[8]) & (eyf[7:0] != 0)) ? (myd << se) : (myd << (eyd[4:0] - 1));
    assign eyr = ((!eyf[8]) & (eyf[7:0] != 0)) ? eyf[7:0] : 8'b0;
    // assign myf = ((!eyf[8]) & (| eyf[7:0])) ? (myd << se) : (myd << (eyd[4:0] - 1));
    // assign eyr = ((!eyf[8]) & (| eyf[7:0])) ? eyf[7:0] : 8'b0;
    // step 19
    assign myr =
        ((myf[1] & (!myf[0]) & (!stck) & myf[2]) | (myf[1] & (!myf[0]) & (s1 == s2) & stck) | (myf[1] & myf[0]))
        ? myf[26:2] + 25'b1
        : myf[26:2];
    // step 20
    assign eyri = eyr + 8'b1;
    // step 21
    assign ey = myr[24] ? eyri : 
                (myr[23:0] != 0) ? eyr : 8'b0;
    assign my = myr[24] ? 23'b0 :
                (myr[23:0] != 0) ? myr[22:0] : 23'b0;
    // step 22
    assign sy = ((ey == 0) & (my == 0)) ? s1 & s2 : ss;
    // step 23
    assign nzm1 = (m1[22:0] != 0);
    assign nzm2 = (m2[22:0] != 0);
    assign y =
        ((e1 == 8'hFF) & (e2 != 8'hFF)) ? {s1,8'hFF,nzm1,m1[21:0]} :
        ((e2 == 8'hFF) & (e1 != 8'hFF)) ? {s2,8'hFF,nzm2,m2[21:0]} :
        ((e1 == 8'hFF) & (e2 == 8'hFF) & nzm2) ? {s2,8'hFF,1'b1,m2[21:0]} :
        ((e1 == 8'hFF) & (e2 == 8'hFF) & nzm1) ? {s1,8'hFF,1'b1,m1[21:0]} :
        ((e1 == 8'hFF) & (e2 == 8'hFF) & (s1 == s2)) ? {s1,8'hFF,23'b0} :
        ((e1 == 8'hFF) & (e2 == 8'hFF)) ? {1'b1,8'hFF,1'b1,22'b0} :
        {sy,ey,my};
    assign ovf = ((e1 != 8'hFF) & (e2 != 8'hFF) & (ey == 8'hFF));
endmodule

`default_nettype wire