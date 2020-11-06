`timescale 1ns / 100ps
`default_nettype none

module rams_init_file #(parameter MEM = 10) (clk, we, addr, din, dout);
    input wire clk;
    input wire we;
    input [MEM-1:0] addr;
    input [31:0] din;
    output [31:0] dout;

    reg [31:0] ram [0:(1<<MEM)-1];
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
