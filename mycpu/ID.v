module ID
#(
    parameter ID2EX_WD = 50,
    parameter WB2RF_WD = 50
) (
    input wire clk,
    input wire rst_n,
    input wire [5:0] stall,
    input wire br_e,
    output wire stallreq_id,

    input wire pc_valid,
    input wire [63:0] pc,
    input wire [63:0] inst_sram_rdata,

    input wire [WB2RF_WD-1:0] wb2rf_bus,
    output wire [ID2EX_WD-1:0] id2ex_bus
);

    reg pc_valid_r;
    reg [63:0] pc_r;

    wire [1:0] sel_src1;
    wire sel_src2;
    wire [4:0] rs1, rs2;
    wire [63:0] imm;
    wire [9:0] alu_op;
    wire [7:0] bru_op;
    wire [6:0] lsu_op;
    wire [9:0] csr_op;
    wire [2:0] sel_rf_res;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [63:0] rdata1, rdata2;

    always @ (posedge clk)begin
        if (!rst_n | br_e) begin
            pc_valid_r <= 1'b0;
            pc_r <= 64'b0;
        end
        else if (stall[1]&(!stall[2]))begin
            pc_valid_r <= 1'b0;
            pc_r <= 64'b0;
        end
        else if (!stall[1]) begin
            pc_valid_r <= pc_valid;
            pc_r <= pc;
        end
    end

    reg [63:0] inst_r;
    reg stall_flag;
    always @ (posedge clk) begin
        if (!rst_n) begin
            inst_r <= 64'b0;
            stall_flag <= 1'b0;
        end
        else if (!stall[1]) begin
            inst_r <= inst_sram_rdata;
            stall_flag <= 1'b0;
        end
        else if (stall_flag) begin
            
        end
        else if (stall[1]&stall[2]) begin
            inst_r <= inst_sram_rdata;
            stall_flag <= 1'b1;
        end
    end

    wire [31:0] inst;
    wire [63:0] inst_tmp;
    assign inst_tmp = stall_flag ? inst_r : inst_sram_rdata;
    assign inst = pc_r[2] ? inst_tmp[63:32] : inst_tmp[31:0];

    decoder_64i u_decoder_64i(
    	.inst       (inst       ),

        .sel_src1   (sel_src1   ),
        .sel_src2   (sel_src2   ),
        .rs1        (rs1        ),
        .rs2        (rs2        ),
        .imm        (imm        ),
        .alu_op     (alu_op     ),
        .bru_op     (bru_op     ),
        .lsu_op     (lsu_op     ),
        .csr_op     (csr_op     ),
        .sel_rf_res (sel_rf_res ),
        .rf_we      (rf_we      ),
        .rf_waddr   (rf_waddr   )
    );

    wire wb_rf_we;
    wire [4:0] wb_rf_waddr;
    wire [63:0] wb_rf_wdata;
    assign {wb_rf_we,wb_rf_waddr,wb_rf_wdata} = wb2rf_bus;

    regfile u_regfile(
    	.clk    (clk    ),
        .rst_n  (rst_n  ),
        .rs1    (rs1    ),
        .rdata1 (rdata1 ),
        .rs2    (rs2    ),
        .rdata2 (rdata2 ),
        .we     (wb_rf_we     ),
        .waddr  (wb_rf_waddr  ),
        .wdata  (wb_rf_wdata  )
    );

    assign id2ex_bus = {
        sel_src1,
        sel_src2,
        rs1,
        rs2,
        rdata1,
        rdata2,
        imm,
        alu_op,
        bru_op & {8{pc_valid_r}},
        lsu_op & {7{pc_valid_r}},
        sel_rf_res,
        rf_we & pc_valid_r,
        rf_waddr & {5{pc_valid_r}},
        pc_r,
        inst & {32{pc_valid_r}}
    };

    reg [6:0] ex_load_buffer;
    always @ (posedge clk) begin
        if (!rst_n) begin
            ex_load_buffer <= 7'b0;
        end
        else if (stall[2]&(!stall[3])) begin
            ex_load_buffer <= 7'b0;
        end
        else if (!stall[2]) begin
            ex_load_buffer <= {sel_rf_res[1],rf_we,rf_waddr};
        end
    end
    wire ex_is_load;
    wire ex_rf_we;
    wire [4:0] ex_rf_waddr;
    assign {ex_is_load,ex_rf_we,ex_rf_waddr} = ex_load_buffer;
    wire stallreq_load;
    assign stallreq_load = ex_is_load & ex_rf_we & ((ex_rf_waddr==rs1 & rs1!=0)|(ex_rf_waddr==rs2 & rs2!=0));
    assign stallreq_id = stallreq_load;
    
endmodule
