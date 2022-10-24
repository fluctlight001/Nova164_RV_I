module bru(
    input wire [63:0] pc,
    input wire [7:0] bru_op,
    input wire [63:0] rdata1,
    input wire [63:0] rdata2,
    input wire [63:0] imm,

    output wire br_e,
    output wire [63:0] br_addr,
    output wire [63:0] br_result
);

    wire inst_beq, inst_bne, inst_blt, inst_bge, inst_bltu, inst_bgeu, inst_jal, inst_jalr;
    assign {
        inst_jal, inst_jalr, inst_beq, inst_bne,
        inst_blt, inst_bge, inst_bltu, inst_bgeu
    } = bru_op;

    wire rs1_eq_rs2;
    wire rs1_ne_rs2;
    wire rs1_lt_rs2;
    wire rs1_ltu_rs2;
    wire rs1_ge_rs2;
    wire rs1_geu_rs2;

    assign rs1_eq_rs2 = ~rs1_ne_rs2;
    assign rs1_ne_rs2 = |(rdata1 ^ rdata2);
    assign rs1_lt_rs2 = ($signed(rdata1) < $signed(rdata2));
    assign rs1_ltu_rs2 = rdata1 < rdata2;
    assign rs1_ge_rs2 = ~rs1_lt_rs2;
    assign rs1_geu_rs2 = ~rs1_ltu_rs2;

    wire [63:0] pc_plus_imm;
    wire [63:0] rs_plus_imm;
    assign pc_plus_imm = pc + imm;
    assign rs_plus_imm = (rdata1 + imm) & (~1);

    assign br_e = inst_beq & rs1_eq_rs2
                | inst_bne & rs1_ne_rs2
                | inst_blt & rs1_lt_rs2
                | inst_bltu & rs1_ltu_rs2
                | inst_bge & rs1_ge_rs2
                | inst_bgeu & rs1_geu_rs2
                | inst_jal
                | inst_jalr;
    assign br_addr = inst_beq | inst_bne | inst_blt | inst_bltu | inst_bge | inst_bgeu | inst_jal ? pc_plus_imm 
                    :inst_jalr ? rs_plus_imm : 64'b0;
    assign br_result = pc + 4'd4;

endmodule
