/* alu module: Archmetci login unit, combinational digital circuit
** input: 
** alu_op:      the control signal to decide which operations
** alu_src1:    the first operand 
** alu_src2:    the second operand 
** alu_result:  the archmetic result
*/
module alu(
    input wire [14:0] alu_op,
    input wire [63:0] alu_src1,
    input wire [63:0] alu_src2,
    output wire [63:0] alu_result
);

    wire op_and;
    wire op_or;
    wire op_xor;
    wire op_add;
    wire op_sub;
    wire op_slt;
    wire op_sltu;
    wire op_sll;
    wire op_srl;
    wire op_sra;
    wire op_addw;
    wire op_subw;
    wire op_sllw;
    wire op_srlw;
    wire op_sraw;
    assign {op_and, op_or, op_xor, op_add, 
      op_sub, op_slt, op_sltu, op_sll, op_srl, op_sra, op_addw, op_subw, op_sllw, op_srlw, op_sraw} = alu_op;

    wire [63:0] and_result;
    wire [63:0] or_result; 
    wire [63:0] xor_result;
    wire [63:0] add_sub_result;
    wire [63:0] slt_result;
    wire [63:0] sltu_result;
    wire [63:0] sll_result;
    wire [63:0] srl_result;
    wire [63:0] sra_result;
    wire [31:0] addw_subw_result;
    wire [31:0] sllw_result;
    wire [31:0] srlw_result;
    wire [31:0] sraw_result;
    
    
    wire [63:0] adder_a;
    wire [63:0] adder_b;
    wire        adder_cin;
    wire [63:0] adder_result;
    wire        adder_cout;

    wire [31:0] adder_a_w;
    wire [31:0] adder_b_w;
    wire        adder_cin_w;
    wire [31:0] adder_result_w;
    wire        adder_cout_w;

    
    // we use complement to compute add and sub
    // when sub, we make the src2 negation, and set the cin 1
    // so (src1 - src2) -> (src1 + ~src2 + 1) -> (src1 + (-src2))
    assign adder_a = alu_src1;
    assign adder_b = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;
    assign adder_cin = (op_sub | op_slt | op_sltu) ? 1'b1 : 1'b0;
    assign {adder_cout, adder_result} = adder_a + adder_b + adder_cin;

    // the rv64i in addition to rv32i (the operation is 32 bits)
    assign adder_a_w = alu_src1[31:0];
    assign adder_b_w = (op_subw) ? ~alu_src2[31:0] : alu_src2[31:0];
    assign adder_cin_w = (op_subw) ? 1'b1 : 1'b0;
    assign {adder_cout_w, adder_result_w} = adder_a_w + adder_b_w + adder_cin_w;

    assign and_result = alu_src1 & alu_src2;
    assign or_result = alu_src1 | alu_src2;
    assign xor_result = alu_src1 ^ alu_src2;
    assign add_sub_result = adder_result;
    assign addw_subw_result = adder_result_w;

    assign slt_result[63:1] = 63'b0;
    assign slt_result[0] = (alu_src1[63] & ~alu_src2[63]) 
                         | (~(alu_src1[63]^alu_src2[63]) & adder_result[63]);
    
    assign sltu_result[63:1] = 63'b0;
    assign sltu_result[0] = ~adder_cout;

    assign sll_result = alu_src1 << alu_src2[5:0];
    assign srl_result = alu_src1 >> alu_src2[5:0];
    assign sra_result = ($signed(alu_src1)) >>> alu_src2[5:0];

    // the rv64i in addition to rv32i (the operation is 32 bits)
    assign sllw_result = alu_src1 << alu_src2[4:0];
    assign srlw_result = alu_src1[31:0] >> alu_src2[4:0];
    assign sraw_result = ($signed(alu_src1[31:0])) >>> alu_src2[4:0];

    // for 32 bits, we should snext it to 64 bits
    assign alu_result = ({64{op_and}}             & and_result) 
                      | ({64{op_or}}              & or_result)
                      | ({64{op_xor}}             & xor_result) 
                      | ({64{op_add|op_sub  }}    & add_sub_result)
                      | ({64{op_slt         }} & slt_result)
                      | ({64{op_sltu        }} & sltu_result)
                      | ({64{op_sll         }} & sll_result)
                      | ({64{op_srl         }} & srl_result)
                      | ({64{op_sra         }} & sra_result)
                      | ({64{op_addw|op_subw}} & {{32{addw_subw_result[31]}}, addw_subw_result})
                      | ({64{op_sllw        }} & {{32{sllw_result[31]}}, sllw_result})
                      | ({64{op_srlw        }} & {{32{srlw_result[31]}}, srlw_result})
                      | ({64{op_sraw        }} & {{32{sraw_result[31]}}, sraw_result});
endmodule
