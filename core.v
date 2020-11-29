`timescale 1ns / 100ps
`default_nettype none

module alu (srca, srcb, control, porm, lora, res, zero);
    input wire [31:0] srca, srcb;
    input wire [2:0] control;
    input wire porm, lora;
    output [31:0] res;
    output zero;

    wire signed [31:0] srca_s, srcb_s;
    wire [4:0] shamt;
    wire [31:0] res;
    wire zero;

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
    assign shamt = srcb[4:0];
    assign res =
        control == alu_add_sub  ? (porm ? srca - srcb : srca + srcb)
      : control == alu_shift_l  ? srca << shamt
      : control == alu_lt       ? {31'b0, srca_s < srcb_s}
      : control == alu_lt_u     ? {31'b0, srca < srcb}
      : control == alu_xor      ? srca ^ srcb
      : control == alu_shift_r  ? (lora ? srca_s >>> shamt : srca >> shamt)
      : control == alu_or       ? srca | srcb
                                : srca & srcb;
    assign zero = res == 0;
endmodule

module main_controller(clk, rstn, instr,
    pcwrite, memwrite, memtoreg, regwrite, 
    alusrca, alusrcb, alucontrol, porm, lora, aluzero, 
    misccontrol, 
    rx_ready, tx_ready, next);
    input wire clk, rstn;
    input wire [31:0] instr;
    input wire aluzero, rx_ready;
    output pcwrite, memwrite, regwrite, porm, lora, tx_ready, next;
    output [1:0] alusrca;
    output [2:0] memtoreg, alusrcb, alucontrol, misccontrol;

    reg pcwrite, memwrite, regwrite, porm, lora, tx_ready, next;
    reg [1:0] alusrca;
    reg [2:0] memtoreg, alusrcb, alucontrol, misccontrol;
    reg [4:0] state;
    wire [4:0] opcode, rd;
    wire [2:0] funct3;
    wire [2:0] imm;

    localparam s_nextpc     = 5'h00;
    localparam s_fetch      = 5'h01;
    localparam s_decode     = 5'h03;
    localparam s_memaddr    = 5'h04;
    localparam s_memread    = 5'h05;
    localparam s_writeback  = 5'h06;
    localparam s_memwrite   = 5'h07;
    localparam s_transmit   = 5'h08;
    localparam s_arimm_exec = 5'h09;
    localparam s_alu_wb     = 5'h0A;
    localparam s_ari_exec   = 5'h0B;
    localparam s_compare    = 5'h0C;
    localparam s_branch     = 5'h0D;
    localparam s_lui_read   = 5'h0E;
    localparam s_auipc_read = 5'h0F;
    localparam s_link_rd    = 5'h10;
    localparam s_jump       = 5'h11;
    localparam s_recv_wait  = 5'h12;
    localparam s_recv_wb    = 5'h13;
    localparam s_misc_exec  = 5'h14;
    localparam s_misc_wb    = 5'h15;
    localparam s_halt       = 5'h1E;
    localparam s_init       = 5'h1F;

    localparam op_load      = 5'h00;
    localparam op_rx        = 5'h02;
    localparam op_arith_imm = 5'h04;
    localparam op_auipc     = 5'h05;
    localparam op_tx        = 5'h06;
    localparam op_store     = 5'h08;
    localparam op_arith     = 5'h0C;
    localparam op_lui       = 5'h0D;
    localparam op_misc      = 5'h16;
    localparam op_branch    = 5'h18;
    localparam op_jalr      = 5'h19;
    localparam op_jal       = 5'h1B;

    localparam mem2reg_alu  = 3'b000;
    localparam mem2reg_misc = 3'b010;
    localparam mem2reg_mem  = 3'b011;
    localparam mem2reg_rx   = 3'b100;

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
    assign rd = instr[11:7];
    assign funct3 = instr[14:12];
    assign imm =
        opcode == op_load       ? srcb_i
      : opcode == op_arith_imm  ? srcb_i
      : opcode == op_auipc      ? srcb_u
      : opcode == op_store      ? srcb_s
      : opcode == op_lui        ? srcb_u
      : opcode == op_branch     ? srcb_sb
      : opcode == op_jalr       ? srcb_i
      : opcode == op_jal        ? srcb_uj
                                : srcb_undef;

    always @(posedge clk) begin
        if (~rstn) begin
            pcwrite <= 0;
            memwrite <= 0;
            memtoreg <= 0;
            regwrite <= 0;
            alusrca <= 0;
            alusrcb <= 0;
            alucontrol <= 0;
            misccontrol <= 0;
            porm <= 0;
            lora <= 0;
            tx_ready <= 0;
            next <= 0;
            state <= s_init;
        end else begin
            if (state == s_writeback
             || state == s_memwrite
             || state == s_transmit
             || state == s_alu_wb
             || state == s_misc_wb
             || state == s_recv_wb) begin
                state <= s_nextpc;
                pcwrite <= 1;
                alusrca <= 2'b00;
                alusrcb <= 3'b001;
                alucontrol <= alu_add_sub;
                porm <= 0;
                regwrite <= 0;  // s_writeback
                memwrite <= 0;  // s_memwrite
                tx_ready <= 0;  // s_transimt
            end else if (state == s_init
             || state == s_nextpc
             || state == s_branch
             || state == s_jump) begin
                state <= s_fetch;
                pcwrite <= 0;   // s_nextpc,s_branch,s_jump
                regwrite <= 0;  // s_jump
            end else if (state == s_fetch) begin
                state <= s_decode;
            end else if (state == s_decode) begin
                if (instr == 0) begin
                    state <= s_halt;
                end else if (opcode == op_load
                          || opcode == op_store) begin
                    state <= s_memaddr;
                    alusrca <= 2'b01;
                    alusrcb <= imm;
                    alucontrol <= alu_add_sub;
                    porm <= 0;
                end else if (opcode == op_rx) begin
                    state <= s_recv_wait;
                    next <= 1;
                end else if (opcode == op_tx) begin
                    state <= s_transmit;
                    tx_ready <= 1;
                end else if (opcode == op_arith_imm) begin
                    state <= s_arimm_exec;
                    alusrca <= 2'b01;
                    alusrcb <= imm;
                    alucontrol <= funct3;
                    porm <= 0;
                    lora <= instr[30];
                end else if (opcode == op_arith) begin
                    state <= s_ari_exec;
                    alusrca <= 2'b01;
                    alusrcb <= 3'b000;
                    alucontrol <= funct3;
                    porm <= instr[30];
                    lora <= instr[30];
                end else if (opcode == op_misc) begin
                    state <= s_misc_exec;
                    alusrca <= 2'b01;
                    alusrcb <= 3'b000;
                    misccontrol <= funct3;
                end else if (opcode == op_branch) begin
                    state <= s_compare;
                    alusrca <= 2'b01;
                    alusrcb <= 3'b000;
                    alucontrol <= {1'b0, funct3[2:1]};
                    porm <= 1;
                end else if (opcode == op_lui) begin
                    state <= s_lui_read;
                    alusrca <= 2'b10;
                    alusrcb <= imm;
                    alucontrol <= alu_add_sub;
                    porm <= 0;
                end else if (opcode == op_auipc) begin
                    state <= s_auipc_read;
                    alusrca <= 2'b00;
                    alusrcb <= imm;
                    alucontrol <= alu_add_sub;
                    porm <= 0;
                end else if (opcode == op_jal
                          || opcode == op_jalr) begin
                    state <= s_link_rd;
                    alusrca <= 2'b00;
                    alusrcb <= 3'b001;
                    alucontrol <= alu_add_sub;
                    porm <= 0;
                end else begin
                    state <= s_halt;
                end
            end else if (state == s_memaddr) begin
                if (opcode == op_load) begin
                    state <= s_memread;
                end else if (opcode == op_store) begin
                    state <= s_memwrite;
                    memwrite <= 1;
                end
            end else if (state == s_memread) begin
                state <= s_writeback;
                memtoreg <= mem2reg_mem;
                regwrite <= 1;
            end else if (state == s_arimm_exec
                      || state == s_ari_exec
                      || state == s_lui_read
                      || state == s_auipc_read) begin
                state <= s_alu_wb;
                memtoreg <= mem2reg_alu;
                regwrite <= 1;
            end else if (state == s_misc_exec) begin
                state <= s_misc_wb;
                memtoreg <= mem2reg_misc;
                regwrite <= 1;
            end else if (state == s_compare) begin
                state <= s_branch;
                alusrca <= 2'b00;
                alusrcb <= (aluzero ^ funct3[0] ^ (alucontrol != 0)) ? imm : 3'b001;
                alucontrol <= alu_add_sub;
                porm <= 0;
                pcwrite <= 1;
            end else if (state == s_link_rd) begin
                state <= s_jump;
                alusrca <= opcode == op_jal ? 2'b00 : 2'b01;
                alusrcb <= imm;
                alucontrol <= alu_add_sub;
                porm <= 0;
                regwrite <= rd != 0;
                pcwrite <= 1;
            end else if (state == s_recv_wait) begin
                if (rx_ready) begin
                    state <= s_recv_wb;
                    next <= 0;
                    memtoreg <= mem2reg_rx;
                    regwrite <= 1;
                end
            end
        end
    end
endmodule

module core #(parameter MEM = 10) (
    clk, rstn, 
    pcaddr, instr,
    memwe, memaddr, memdin, memdout,
    a0out, 
    rdata, rx_ready, next, sdata, tx_ready);
    input wire clk, rstn;
    output memwe;
    output [MEM-3:0] pcaddr;
    output [MEM-1:0] memaddr;
    output [31:0] memdin;
    input wire [31:0] instr;
    input wire [31:0] memdout;
    input wire [7:0] rdata;
    input wire rx_ready;
    output [7:0] a0out;
    output [7:0] sdata;
    output tx_ready, next;

    // block RAM
    wire memwe;
    wire [MEM-3:0] pcaddr;
    wire [MEM-1:0] memaddr;
    wire [31:0] memdin;
    wire [7:0] a0out;
    // registers
    reg [31:0] x [31:0]; // registers
    reg [MEM-1:0] pc;
    // control
    wire pcwrite, memwrite, regwrite, porm, lora;
    wire [1:0] alusrca;
    wire [2:0] memtoreg, alusrcb;
    wire [2:0] alucontrol, misccontrol;
    // units
    reg [31:0] aluout, miscout;
    // uart
    wire [7:0] sdata;
    wire tx_ready, next;

    wire [4:0] rs1, rs2, rd;
    wire [31:0] I_imm, S_imm, U_imm, SB_imm, UJ_imm;
    wire [31:0] writedata;
    reg [31:0] a, b;
    wire [31:0] srca, srcb;
    wire [31:0] aluresult, miscresult;
    wire aluzero;

    localparam reg_zero = 5'h00;
    localparam reg_sp   = 5'h02;
    localparam reg_gp   = 5'h03;
    localparam reg_hp   = 5'h05;
    localparam reg_a0   = 5'h0A;

    assign memwe = memwrite;
    assign pcaddr = pc[MEM-1:2];
    assign memaddr = aluout[MEM+1:2];
    assign memdin = b;
    assign a0out = x[reg_a0][7:0];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign writedata =
        memtoreg == 3'b000 ? aluout
      : memtoreg == 3'b010 ? miscout
      : memtoreg == 3'b011 ? memdout
                           : {24'b0, rdata};
    assign I_imm = {{20{instr[31]}}, instr[31:20]};
    assign S_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign U_imm = {instr[31:12], 12'b0};
    assign SB_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    assign UJ_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    assign srca =
        alusrca == 2'b00 ? {22'b0, pc}
      : alusrca == 2'b01 ? a
                         : 0;
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

    alu alu_0(srca, srcb, alucontrol, porm, lora, aluresult, aluzero);
    misc misc_0(srca, srcb, misccontrol, miscresult);
    main_controller main_controller_0(clk, rstn, instr,
        pcwrite, memwrite, memtoreg, regwrite, alusrca, alusrcb, alucontrol, porm, lora, aluzero, misccontrol, 
        rx_ready, tx_ready, next);

    always @(posedge clk) begin
        if (~rstn) begin
            x[reg_zero] <= 32'h0;
            x[reg_sp] <= 2 << (MEM - 2);
            x[reg_gp] <= 0;
            x[reg_hp] <= 1 << (MEM - 2);
            pc <= 128;
            a <= 0;
            b <= 0;
            aluout <= 0;
            miscout <= 0;
        end else begin
            pc <= pcwrite ? aluresult[MEM-1:0] : pc;
            a <= x[rs1];
            b <= x[rs2];
            aluout <= aluresult;
            miscout <= miscresult;
            x[rd] <= regwrite ? writedata : x[rd];
        end
    end
endmodule
