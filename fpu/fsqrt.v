`default_nettype none
`timescale 10ps / 1ps

module fsqrt_table (clk, addr, value);
    input wire clk;
    input [9:0] addr;
    output [35:0] value;

    reg [35:0] ram [0:(1<<10)-1];
    reg [35:0] value;

    initial begin
        $readmemh("fsqrt_table.mem", ram);
    end

    always @(posedge clk) begin
        value <= ram[addr];
    end
endmodule

module fsqrt (
    input wire [31:0] x1, 
    input wire clk,
    input wire rstn,
    output wire [31:0] y
    );

    // Wires 
    // Stage 1
    wire        s1;
    wire [7:0]  e1;
    wire [22:0] m1;
    wire [8:0]  a0;
    wire [13:0] a1;
    wire [9:0]  key;
    wire [35:0] ck;
    // Stage 2
    wire [22:0] c1;
    wire [12:0] k1;
    wire [23:0] c2;
    wire [13:0] k2;
    wire [27:0] d1;
    wire [23:0] d2;
    wire [23:0] m2;
    wire [7:0]  e2;
    wire [22:0] m3;
    // Registers
    reg [31:0] x1_reg;
    reg [13:0] a1_reg;
    reg        s1_reg;
    reg [7:0]  e1_reg;
    reg [22:0] m1_reg;


    // Implementation
    // Stage 1 : split x into sign, exponent, mantissa.
    assign s1 = x1[31];
    assign e1 = x1[30:23];
    assign m1 = x1[22:0];
    // Mantissa 23 bit -> High bit (9 bit) + Low bit (14 bit)
    assign a0 = m1[22:14]; 
    assign a1 = m1[13:0];
    assign key = x1[23:14];
    // Draw 36 bit from the table -> c (23 bit) + k (13 bit)
    fsqrt_table fsqrt_table_0(clk, key, ck);

    // Stage 2 : Newton Raphson method.
    assign c1 = ck[35:13];   // 23 bit
    assign k1 = ck[12:0];    // 13 bit
    assign c2 = {1'b1, c1};  // 24 bit
    assign k2 = {1'b1, k1};  // 14 bit
    assign d1 = k2 * a1_reg; // 28 bit
    assign d2 = (e1_reg[0] == 1) ? {11'b0, d1[27:15]} : {10'b0, d1[27:14]}; // 24 bit
    assign m2 = c2 + d2;     // 24 bit
    // Conclude exponent and mantissa.
    assign e2 = (e1_reg >> 1) + ((e1_reg[0]==1) ? 64 : 63);
    assign m3 = ((e1_reg[0] == 1) && (m1_reg==23'b0)) ? 23'b0 : m2[22:0];
    assign y = (x1_reg == 32'b0) ? 32'b0 : {s1_reg, e2, m3};

    always @(posedge clk) begin
        if (~rstn) begin
            x1_reg <= 32'b0;
            a1_reg <= 14'b0;
            s1_reg <= 1'b0;
            e1_reg <= 8'b0;
            m1_reg <= 23'b0;
        end else begin
            x1_reg <= x1;
            a1_reg <= a1;
            s1_reg <= s1;
            e1_reg <= e1;
            m1_reg <= m1;
        end
    end
endmodule
