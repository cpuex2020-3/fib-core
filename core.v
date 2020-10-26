`timescale 1ns / 100ps
`default_nettype none

module alu (srca, srcb, control, porm, lora, res);
    input wire [31:0] srca, srcb;
    input wire [2:0] control;
    input wire porm, lora;
    output [31:0] res;

    wire signed [31:0] srca_s, srcb_s;
    wire [31:0] res;

    localparam alu_add_sub  = 3'b000;
    localparam alu_shift_l  = 3'b001;
    localparam alu_lt       = 3'b010;
    localparam alu_lt_u     = 3'b011;
    localparam alu_xor      = 3'b100;
    localparam alu_shift_r  = 3'b101;
    localparam alu_or       = 3'b110;
    localparam alu_and      = 3'b111;

    assign srca_s = srca;
    assign srcb_s = srcb;
    assign res =
        control == alu_add_sub  ? (porm ? srca - srcb : srca + srcb)
      : control == alu_shift_l  ? srca << srcb[5:0]
      : control == alu_lt       ? {31'b0, srca_s < srcb_s}
      : control == alu_lt_u     ? {31'b0, srca < srcb}
      : control == alu_xor      ? srca ^ srcb
      : control == alu_shift_r  ? (lora ? srca_s >>> srcb[5:0] : srca >> srcb[5:0])
      : control == alu_or       ? srca | srcb
                                : srca & srcb;
endmodule

module main_controller(clk, rstn, instr,
    pcwrite, iord, memwrite, irwrite, memtoreg, regwrite, 
    alusrca, alusrcb, alucontrol, porm, lora, tx_ready);
    input wire clk, rstn;
    input wire [31:0] instr;
    output pcwrite, iord, memwrite, irwrite, memtoreg, regwrite, alusrca, porm, lora, tx_ready;
    output [2:0] alusrcb, alucontrol;

    reg pcwrite, iord, memwrite, irwrite, memtoreg, regwrite, alusrca, porm, lora, tx_ready;
    reg [2:0] alusrcb, alucontrol;
    reg [4:0] state;
    wire [4:0] opcode;
    wire [2:0] funct3;
    wire [2:0] imm;

    localparam s_fetch0     = 5'h00;
    localparam s_fetch1     = 5'h01;
    localparam s_fetch2     = 5'h02;
    localparam s_decode     = 5'h03;
    localparam s_memaddr    = 5'h04;
    localparam s_memread    = 5'h05;
    localparam s_writeback  = 5'h06;
    localparam s_memwrite   = 5'h07;
    localparam s_transmit   = 5'h08;
    localparam s_arimm_exec = 5'h09;
    localparam s_alu_wb     = 5'h0A;
    localparam s_ari_exec   = 5'h0B;
    localparam s_halt       = 5'h1E;
    localparam s_init       = 5'h1F;

    localparam op_load      = 5'h00;
    localparam op_arith_imm = 5'h04;
    localparam op_store     = 5'h08;
    localparam op_arith     = 5'h0C;
    localparam op_tx        = 5'h1F;

    localparam srcb_i       = 3'b010;
    localparam srcb_s       = 3'b011;
    localparam srcb_u       = 3'b100;
    localparam srcb_sb      = 3'b101;
    localparam srcb_uj      = 3'b110;
    localparam srcb_undef   = 3'b111;

    localparam alu_add_sub  = 3'b000;
    localparam alu_shift_l  = 3'b001;
    localparam alu_lt       = 3'b010;
    localparam alu_lt_u     = 3'b011;
    localparam alu_xor      = 3'b100;
    localparam alu_shift_r  = 3'b101;
    localparam alu_or       = 3'b110;
    localparam alu_and      = 3'b111;

    assign opcode = instr[6:2];
    assign funct3 = instr[14:12];
    assign imm =
        opcode == op_load       ? srcb_i
      : opcode == op_arith_imm  ? srcb_i
      : opcode == op_store      ? srcb_s
                                : srcb_undef;

    always @(posedge clk) begin
        if (~rstn) begin
            pcwrite <= 0;
            iord <= 0;
            memwrite <= 0;
            irwrite <= 0;
            memtoreg <= 0;
            regwrite <= 0;
            alusrca <= 0;
            alusrcb <= 0;
            alucontrol <= 0;
            porm <= 0;
            lora <= 0;
            state <= s_init;
        end else begin
            if (state == s_init
             || state == s_writeback
             || state == s_memwrite
             || state == s_transmit
             || state == s_alu_wb) begin
                state <= s_fetch0;
                pcwrite <= 1;
                alusrca <= 0;
                alusrcb <= 3'b001;
                alucontrol <= alu_add_sub;
                porm <= 0;
                regwrite <= 0;  // s_writeback
                memwrite <= 0;  // s_memwrite
                tx_ready <= 0;  // s_transimt
            end else if (state == s_fetch0) begin
                state <= s_fetch1;
                pcwrite <= 0;   // s_fetch0
                iord <= 0;
            end else if (state == s_fetch1) begin
                state <= s_fetch2;
                irwrite <= 1;
            end else if (state == s_fetch2) begin
                state <= s_decode;
                irwrite <= 0;   // s_fetch2
            end else if (state == s_decode) begin
                if (instr == 0) begin
                    state <= s_halt;
                end else if (opcode == op_load
                          || opcode == op_store) begin
                    state <= s_memaddr;
                    alusrca <= 1;
                    alusrcb <= imm;
                    alucontrol <= alu_add_sub;
                    porm <= 0;
                end else if (opcode == op_tx) begin
                    state <= s_transmit;
                    tx_ready <= 1;
                end else if (opcode == op_arith_imm) begin
                    state <= s_arimm_exec;
                    alusrca <= 1;
                    alusrcb <= imm;
                    alucontrol <= funct3;
                    porm <= 0;
                    lora <= instr[30];
                end else if (opcode == op_arith) begin
                    state <= s_ari_exec;
                    alusrca <= 1;
                    alusrcb <= 0;
                    alucontrol <= funct3;
                    porm <= instr[30];
                    lora <= instr[30];
                end else begin
                    state <= s_halt;
                end
            end else if (state == s_memaddr) begin
                if (opcode == op_load) begin
                    state <= s_memread;
                    iord <= 1;
                end else if (opcode == op_store) begin
                    state <= s_memwrite;
                    memwrite <= 1;
                    iord <= 1;
                end
            end else if (state == s_memread) begin
                state <= s_writeback;
                memtoreg <= 1;
                regwrite <= 1;
            end else if (state == s_arimm_exec
                      || state == s_ari_exec) begin
                state <= s_alu_wb;
                memtoreg <= 0;
                regwrite <= 1;
            end
        end
    end
endmodule

module core (clk, rstn, 
    memwe, memaddr, memdin, memdout,
    a0out, sdata, tx_ready);
    input wire clk, rstn;
    output memwe;
    output [7:0] memaddr;
    output [31:0] memdin;
    input wire [31:0] memdout;
    output [7:0] a0out;
    output [7:0] sdata;
    output tx_ready;

    // block RAM
    wire memwe;
    wire [7:0] memaddr;
    wire [31:0] memdin;
    wire [7:0] a0out;
    // registers
    reg [31:0] x [31:0]; // registers
    reg [8:0] pc;
    // controll
    wire pcwrite, iord, memwrite, irwrite, memtoreg, regwrite, alusrca, porm, lora;
    wire [2:0] alusrcb;
    wire [2:0] alucontrol;
    // outputs
    reg [31:0] aluout;
    wire [7:0] sdata;
    wire tx_ready;

    reg [31:0] instr;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] I_imm, S_imm, U_imm, SB_imm, UJ_imm;
    wire [31:0] writedata;
    reg [31:0] a, b;
    wire [31:0] srca, srcb;
    wire [31:0] aluresult;

    localparam reg_zero = 5'h00;
    localparam reg_gp   = 5'h03;

    assign memwe = memwrite;
    assign memaddr = iord ? aluout[9:2] : {1'b0, pc[8:2]};
    assign memdin = b;
    assign a0out = x[10][7:0];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign writedata = memtoreg ? memdout : aluout;
    assign I_imm = {{20{instr[31]}}, instr[31:20]};
    assign S_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign U_imm = {instr[31:12], 12'b0};
    assign SB_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    assign UJ_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    assign srca = alusrca ? a : {23'b0, pc};
    assign srcb =
        alusrcb == 3'b000 ? b
      : alusrcb == 3'b001 ? 4
      : alusrcb == 3'b010 ? I_imm
      : alusrcb == 3'b011 ? S_imm
      : alusrcb == 3'b100 ? U_imm
      : alusrcb == 3'b101 ? SB_imm
      : alusrcb == 3'b110 ? UJ_imm
                          : 0;
    assign sdata = a[7:0];

    alu alu_0(srca, srcb, alucontrol, porm, lora, aluresult);
    main_controller main_controller_0(clk, rstn, instr,
        pcwrite, iord, memwrite, irwrite, memtoreg, regwrite, alusrca, alusrcb, alucontrol, porm, lora, tx_ready);

    always @(posedge clk) begin
        if (~rstn) begin
            x[reg_zero] <= 32'h0;
            x[reg_gp] <= 32'h200;
            pc <= 9'h1FC;
            instr <= 0;
            a <= 0;
            b <= 0;
            aluout <= 0;
        end else begin
            pc <= pcwrite ? aluresult[8:0] : pc;
            instr <= irwrite ? memdout : instr;
            a <= x[rs1];
            b <= x[rs2];
            aluout <= aluresult;
            x[rd] <= regwrite ? writedata : x[rd];
        end
    end
endmodule
