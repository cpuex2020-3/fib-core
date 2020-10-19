`timescale 1ns / 100ps
`default_nettype none

module rams_init_file (clk, we, addr, din, dout);
    input wire clk;
    input wire we;
    input [7:0] addr;
    input [31:0] din;
    output [31:0] dout;

    reg [31:0] ram [0:255];
    reg [31:0] dout;

    initial begin
        $readmemh("rams_init_file.data",ram);
    end

    always @(posedge clk) begin
        if (we)
            ram[addr] <= din;
        dout <= ram[addr];
    end
endmodule
