`timescale 1ns / 100ps
`default_nettype none

module alu (srca, srcb, res, ctrl);
    input wire [31:0] srca, srcb;
    input wire [2:0] ctrl;
    output [31:0] res;

    wire [31:0] res;

    assign res = srca + srcb;
endmodule

module main_controller(clk, rstn,
    instr, 
    iord, alusrca, alusrcb, irwrite, pcwrite, regwrite, alucontrol);
    input wire clk, rstn;
    input wire [31:0] instr;
    output iord, alusrca, irwrite, pcwrite, regwrite;
    output [1:0] alusrcb;
    output [2:0] alucontrol;

    reg iord, alusrca, irwrite, pcwrite, regwrite;
    reg [1:0] alusrcb;
    reg [2:0] alucontrol;
    reg [3:0] state;

    always @(posedge clk) begin
        if (~rstn) begin
            iord <= 0;
            alusrca <= 0;
            alusrcb <= 0;
            irwrite <= 0;
            pcwrite <= 0;
            regwrite <= 0;
            alucontrol <= 0;
            state <= 4'h4;
        end else begin
            if (state == 4'h4) begin
                regwrite <= 0; // from S4
                iord <= 0;
                alusrca <= 0;
                alusrcb <= 2'b01;
                irwrite <= 1;
                pcwrite <= 1;
                state <= 4'h0;
            end else if (state == 4'h0) begin
                irwrite <= 0; // from S0
                pcwrite <= 0; // from S0
                alusrca <= 0;
                alusrcb <= 2'b11;
                state <= 4'h1;
            end else if (state == 4'h1) begin
                if (instr[1:0] == 2'b11) begin
                    state <= 4'h2;
                    alusrca <= 1;
                    alusrcb <= 2'b10;
                    state <= 4'h2;
                end else begin
                    state <= 4'hE; // halt
                end
            end else if (state == 4'h2) begin
                iord <= 1;
                state <= 4'h3;
            end else if (state == 4'h3) begin
                regwrite <= 1;
                state <= 4'h4;
            end else if (state == 4'hF) begin
                state <= 4'h0;
            end
        end
    end
endmodule

module core (clk, rstn, 
    memwe, memaddr, memdin, memdout,
    a0out);
    input wire clk, rstn;
    output memwe;
    output [7:0] memaddr;
    output [31:0] memdin;
    input wire [31:0] memdout;
    output [7:0] a0out;

    reg memwe;
    reg [7:0] memaddr;
    reg [31:0] memdin;
    wire [7:0] a0out;
    reg [31:0] x [31:0]; // registers
    reg [6:0] pc;
    wire [6:0] pc_;      // program counter
    reg [31:0] instr;
    wire irwrite, iord, regwrite, pcwrite;
    wire [2:0] alucontrol;
    wire [4:0] I_rs1, I_rd;
    reg [31:0] rd1;
    reg [31:0] a;
    wire [31:0] I_imm;
    wire [31:0] aluresult;
    reg [31:0] aluout;
    reg [31:0] data;
    wire [31:0] srca, srcb;
    wire alusrca;
    wire [1:0] alusrcb;

    assign a0out = x[10][7:0];
    assign I_rs1 = instr[19:15];
    assign I_imm = {{20{instr[31]}}, instr[31:20]};
    assign I_rd = instr[11:7];
    assign srca = alusrca ? a : {25'b0, pc};
    assign srcb =
        alusrcb == 2'b00 ? 0
      : alusrcb == 2'b01 ? I_imm
      : alusrcb == 2'b10 ? 1
                         : 0;
    assign pc_ = aluout[6:0];

    alu alu_0(srca, srcb, aluresult, alucontrol);
    main_controller main_controller_0(clk, rstn, instr, 
        iord, alusrca, alusrcb, irwrite, pcwrite, regwrite, alucontrol);

    always @(posedge clk) begin
        if (~rstn) begin
            memwe <= 0;
            memaddr <= 0;
            memdin <= 0;
            x[0] <= 0;
            pc <= 0;
            instr <= 0;
            rd1 <= 0;
            a <= 0;
            aluout <= 0;
            data <= 0;
        end else begin
            pc <= pcwrite ? pc_ : pc;
            memaddr <= iord ? aluout[7:0] : {1'b0, pc_};
            instr <= irwrite ? memdout : instr;
            rd1 <= x[I_rs1];
            a <= rd1;
            aluout <= aluresult;
            data <= memdout;
            if (regwrite)
                x[I_rd] <= data;            
        end
    end
endmodule
