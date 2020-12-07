`timescale 1ns / 100ps
`default_nettype none

module ram_prog #(parameter MEM = 19) (clk, pc, instr);
    input wire clk;
    input [MEM-3:0] pc;
    output [31:0] instr;

    reg [31:0] ram [0:(1<<MEM-2)-1];
    reg [31:0] instr;

    initial begin
        $readmemh("ram_prog.mem", ram);
    end

    always @(posedge clk) begin
        instr <= ram[pc];
    end
endmodule

module ram_data #(parameter MEM = 19) (clk, we, addr, din, dout);
    input wire clk;
    input wire we;
    input [MEM-1:0] addr;
    input [31:0] din;
    output [31:0] dout;

    reg [31:0] ram [0:(3<<MEM-2)-1];
    reg [31:0] dout;

    initial begin
        $readmemh("ram_data.mem", ram);
    end

    always @(posedge clk) begin
        if (we)
            ram[addr] <= din;
        dout <= ram[addr];
    end
endmodule
