module ID
#(
    parameter ID2EX_WD = 49,
    parameter WB2RF_WD = 50) (
    input wire clk,
    input wire rst_n,
    input wire [5:0] stall,
    input wire br_e,
    //when id stallreq
    //ex is load and data 相关
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
    wire [1:0] sel_rf_res;
    wire [14:0] alu_op;
    wire [7:0] bru_op;
    wire [6:0] lsu_op;
    wire [9:0] csr_op;
    wire rf_we;

    wire [4:0] rs1, rs2;
    wire [63:0] rdata1, rdata2;
    wire [63:0] imm;
    wire [4:0] rf_waddr;

    always @ (posedge clk)begin
        if (!rst_n) begin
            pc_valid_r <= 1'b0;
            pc_r <= 64'b0;
        end
        //nop, if stall and id not stall
        else if (stall[1]&(!stall[2]))begin
            pc_valid_r <= 1'b0;
            pc_r <= 64'b0;
        end
        //nop, if not stall and br
        else if (!stall[1]&br_e) begin
            pc_valid_r <= 1'b0;
            pc_r <= 64'b0;
        end
        // if not stall so go on
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
        //if not stall, get inst from inst_sram
        else if (!stall[1]) begin
            inst_r <= inst_sram_rdata;
            stall_flag <= 1'b0;
        end
        else if (stall_flag) begin
            
        end
        //if stall and id stall, get inst from inst_ram ? 
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
        sel_src1,                     //2
        sel_src2,                     //1
        rs1,                          //5
        rs2,                          //5
        rdata1,                       //64
        rdata2,                       //64
        imm,                          //64
        alu_op,                       //15
        bru_op & {8{pc_valid_r}},     //8
        lsu_op & {7{pc_valid_r}},     //7
        sel_rf_res,                   //2
        rf_we & pc_valid_r,           //1
        rf_waddr & {5{pc_valid_r}},   //5
        pc_r,                         //64
        inst & {32{pc_valid_r}}       //32
    };

    //通过时钟，在下一个状态获取，但是放在了ID段（好离谱
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
    //ex段为load指令，且发生数据相关时，id段需要被暂停
    wire stallreq_load;
    assign stallreq_load = ex_is_load & ex_rf_we & ((ex_rf_waddr==rs1 & rs1!=0)|(ex_rf_waddr==rs2 & rs2!=0));
    assign stallreq_id = stallreq_load;
    
endmodule
