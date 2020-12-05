`default_nettype none
`timescale 10ps / 1ps

module fmul (
    input wire [31:0] x1, 
    input wire [31:0] x2,
    output wire [31:0] y,
    output wire ovf);

    // Wires and Registers
    // Stage 1
    // Stage 1-0 (step 1) : Mantissa 23 bit -> High bit (12 bit) + Low bit (11 bit)
    wire s1;
    wire [7:0] e1;
    wire [22:0] m1;
    wire [11:0] stingy_h1;
    wire [10:0] l1;
    wire s2;
    wire [7:0] e2;
    wire [22:0] m2;
    wire [11:0] stingy_h2;
    wire [10:0] l2;
    // Stage 1-1 (step 2) : Calculate HH, HL, LH
    wire [12:0] h1;
    wire [12:0] h2;
    wire [25:0] hh;
    wire [23:0] hl;
    wire [23:0] lh;
    // Stage 1-2 (step 5) : Calculate exp1+exp2+129
    wire [8:0] e3;
    // Stage 1-3 (step 5) : XOR sign bits
    wire s3;

    // Stage 2
    // Stage 2-1 (step 3) : Calculate HH + (HL >> 11) + (LH >> 11) + 2
    wire [25:0] m3;
    // Stage 2-2 : Calculate exponent + 1
    wire [8:0] e4;
    // Stage 3
    // Stage 3-1 : check underflow bit and MSB to select exponent
    wire [7:0] e5;
    // Stage 3-2 (step 4) : normalize mantissa
    wire [22:0] m4;

    // Implementation
    // Stage 1
    // Stage 1-0 (step 1) : Mantissa 23 bit -> High bit (12 bit) + Low bit (11 bit)
    assign s1 = x1[31];
    assign e1 = x1[30:23];
    assign m1 = x1[22:0];
    assign stingy_h1 = x1[22:11];
    assign l1 = x1[10:0];
    assign s2 = x2[31];
    assign e2 = x2[30:23];
    assign m2 = x2[22:0];
    assign stingy_h2 = x2[22:11];
    assign l2 = x2[10:0];
    // Stage 1-1 (step 2) : Calculate HH, HL, LH
    assign h1 = {1'b1,stingy_h1};
    assign h2 = {1'b1,stingy_h2};
    assign hh = h1*h2;
    assign hl = h1*l2;
    assign lh = l1*h2;
    // Stage 1-2 (step 5) : Calculate exp1+exp2+129
    assign e3 = e1+e2+129;
    // Stage 1-3 (step 5) : XOR sign bits
    assign s3 = s1^s2;

    // Stage 2
    // Stage 2-1 (step 3) : Calculate HH + (HL >> 11) + (LH >> 11) + 2
    assign m3 = hh + (hl>>11) + (lh>>11) + 2;
    // Stage 2-2 : Calculate exponent + 1
    assign e4 = e3+1;

    // Stage 3
    // Stage 3-1 : check underflow bit and MSB to select exponent
    assign e5 = (e3[8] == 0) ? 8'b0 : (m3[25] == 1) ? e4[7:0] : e3[7:0];
    // Stage 3-2 (step 4) : normalize mantissa
    assign m4 = (e3[8] == 0) ? 23'b0 :(m3[25] == 1) ? m3[24:2] : m3[23:1];
    // Stage 3-3 : return value
    assign y = {s3, e5, m4};
    assign ovf = 1'b0;


endmodule
