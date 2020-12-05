`default_nettype none
`timescale 10ps / 1ps

module finv_table (clk, addr, value);
    input wire clk;
    input [9:0] addr;
    output [35:0] value;

    reg [35:0] ram [0:(1<<10)-1];
    reg [35:0] value;

    initial begin
        $readmemh("finv_table.mem", ram);
    end

    always @(posedge clk) begin
        value <= ram[addr];
    end
endmodule

module finv (
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
    wire [9:0]  a0;
    wire [12:0] a1;
    wire [35:0] ck;
    // Stage 2
    wire [22:0] c1;
    wire [12:0] k1;
    wire [23:0] c2;
    wire [25:0] d1;
    wire [23:0] d2;
    wire [23:0] m2;
    wire [7:0]  e2;
    wire [22:0] m3;
    // Registers
    reg [12:0] a1_reg;
    reg        s1_reg;
    reg [7:0]  e1_reg;
    reg [22:0] m1_reg;


    // Implementation
    // Stage 1 : split x into sign, exponent, mantissa.
    assign s1 = x1[31];
    assign e1 = x1[30:23];
    assign m1 = x1[22:0];
    // Mantissa 23 bit -> High bit (10 bit) + Low bit (13 bit)
    assign a0 = m1[22:13]; 
    assign a1 = m1[12:0];
    // Draw 36 bit from the table -> c (23 bit) + k (13 bit)
    finv_table finv_table_0(clk, a0, ck);

    // Stage 2 : Newton Raphson method.
    assign c1 = ck[35:13];
    assign k1 = ck[12:0];
    assign c2 = {1'b1, c1};
    // d1 = k1 * a1 : 26 bit -> d2 (significant 14 bit of d1)
    assign d1 = k1 * a1_reg;
    assign d2 = {10'b0, d1[25:12]};
    assign m2 = c2 - d2;
    // Conclude exponent and mantissa.
    assign e2 = (m1_reg == 23'b0) ? 254 - e1_reg : 253 - e1_reg;
    assign m3 = (m1_reg == 23'b0) ? 23'b0 : m2[22:0];
    assign y = {s1_reg, e2, m3};

    always @(posedge clk) begin
        if (~rstn) begin
            a1_reg <= 13'b0;
            s1_reg <= 1'b0;
            e1_reg <= 8'b0;
            m1_reg <= 23'b0;
        end else begin
            a1_reg <= a1;
            s1_reg <= s1;
            e1_reg <= e1;
            m1_reg <= m1;
        end
    end
endmodule
