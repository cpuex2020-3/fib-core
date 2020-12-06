`default_nettype none
`timescale 10ps / 1ps

module fadd_p2 (
        input wire [31:0] x1,
        input wire [31:0] x2,
        output wire [31:0] y,
        input wire clk,
        input wire rstn);

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

    reg [31:0] x1_reg;
    reg [31:0] x2_reg;
    reg s1_reg;
    reg [7:0] e1_reg;
    reg [21:0] m1_reg;
    reg s2_reg;
    reg [7:0] e2_reg;
    reg [21:0] m2_reg;
    reg ss_reg;
    reg [7:0] eyd_reg;
    reg [26:0] myd_reg;
    reg stck_reg;
    reg nzm1_reg;
    reg nzm2_reg;

    // step 1
    assign s1 = x1_reg[31];
    assign e1 = x1_reg[30:23];
    assign m1 = x1_reg[22:0];
    assign s2 = x2_reg[31];
    assign e2 = x2_reg[30:23];
    assign m2 = x2_reg[22:0];
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
    my_priority_encoder pe(myd_reg, se);
    // step 17
    assign eyf = {1'b0,eyd_reg} - {4'b0,se};
    // step 18
    assign myf = ((!eyf[8]) & (eyf[7:0] != 0)) ? (myd_reg << se) : (myd_reg << (eyd_reg[4:0] - 1));
    assign eyr = ((!eyf[8]) & (eyf[7:0] != 0)) ? eyf[7:0] : 8'b0;
    // step 19
    assign myr =
        ((myf[1] & (!myf[0]) & (!stck_reg) & myf[2])
        | (myf[1] & (!myf[0]) & (s1_reg == s2_reg) & stck_reg)
        | (myf[1] & myf[0]))
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
    assign sy = ((ey == 0) & (my == 0)) ? s1_reg & s2_reg : ss_reg;
    // step 23
    assign nzm1 = (m1[22:0] != 0);
    assign nzm2 = (m2[22:0] != 0);
    assign y =
        ((e1_reg == 8'hFF) & (e2_reg != 8'hFF)) ? {s1_reg,8'hFF,nzm1_reg,m1_reg} :
        ((e2_reg == 8'hFF) & (e1_reg != 8'hFF)) ? {s2_reg,8'hFF,nzm2_reg,m2_reg} :
        ((e1_reg == 8'hFF) & (e2_reg == 8'hFF) & nzm2_reg) ? {s2_reg,8'hFF,1'b1,m2_reg} :
        ((e1_reg == 8'hFF) & (e2_reg == 8'hFF) & nzm1_reg) ? {s1_reg,8'hFF,1'b1,m1_reg} :
        ((e1_reg == 8'hFF) & (e2_reg == 8'hFF) & (s1_reg == s2_reg)) ? {s1_reg,8'hFF,23'b0} :
        ((e1_reg == 8'hFF) & (e2_reg == 8'hFF)) ? {1'b1,8'hFF,1'b1,22'b0} :
        {sy,ey,my};

    always @(posedge clk) begin
        if (~rstn) begin
            x1_reg <= 32'b0;
            x2_reg <= 32'b0;
            s1_reg <= 1'b0;
            e1_reg <= 8'b0;
            m1_reg <= 22'b0;
            s2_reg <= 1'b0;
            e2_reg <= 8'b0;
            m2_reg <= 22'b0;
            ss_reg <= 1'b0;
            eyd_reg <= 8'b0;
            myd_reg <= 27'b0;
            stck_reg <= 1'b0;
            nzm1_reg <= 1'b0;
            nzm2_reg <= 1'b0;
        end else begin
            x1_reg <= x1;
            x2_reg <= x2;
            s1_reg <= s1;
            e1_reg <= e1;
            m1_reg <= m1[21:0];
            s2_reg <= s2;
            e2_reg <= e2;
            m2_reg <= m2[21:0];
            ss_reg <= ss;
            eyd_reg <= eyd;
            myd_reg <= myd;
            stck_reg <= stck;
            nzm1_reg <= nzm1;
            nzm2_reg <= nzm2;
        end
    end
endmodule

`default_nettype wire
