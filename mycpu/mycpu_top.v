`define ID2EX_WD 600
`define EX2MEM_WD 600
`define MEM2WB_WD 600
`define WB2RF_WD 600
`define MEM2EX_WD 600
`define WB2EX_WD 600
module mycpu_top #(
  parameter AXI_DATA_WIDTH = 64,
  parameter AXI_ADDR_WIDTH = 32,
  parameter AXI_ID_WIDTH = 4,
  parameter AXI_USER_WIDTH = 1
)(
    input  wire clk,
    input  wire rst_n,
    input  wire ext_int,

    input wire                              core_axi_aw_ready_i,
    output wire                              core_axi_aw_valid_o,
    output wire [AXI_ADDR_WIDTH - 1:0]       core_axi_aw_addr_o,
    output wire [2:0]                        core_axi_aw_prot_o,
    output wire [AXI_ID_WIDTH-1:0]           core_axi_aw_id_o,
    output wire [AXI_USER_WIDTH-1:0]         core_axi_aw_user_o,
    output wire [7:0]                        core_axi_aw_len_o,
    output wire [2:0]                        core_axi_aw_size_o,
    output wire [1:0]                        core_axi_aw_burst_o,
    output wire                              core_axi_aw_lock_o,
    output wire [3:0]                        core_axi_aw_cache_o,
    output wire [3:0]                        core_axi_aw_qos_o,
    output wire [3:0]                        core_axi_aw_region_o,

    input wire                              core_axi_w_ready_i,
    output wire                              core_axi_w_valid_o,
    output wire [AXI_DATA_WIDTH-1:0]         core_axi_w_data_o,
    output wire [AXI_DATA_WIDTH/8-1:0]       core_axi_w_strb_o,
    output wire                              core_axi_w_last_o,
    output wire [AXI_USER_WIDTH-1:0]         core_axi_w_user_o,

    output wire                              core_axi_b_ready_o,
    input wire                              core_axi_b_valid_i,
    input wire [1:0]                        core_axi_b_resp_i,
    input wire [AXI_ID_WIDTH-1:0]           core_axi_b_id_i,
    input wire [AXI_USER_WIDTH-1:0]         core_axi_b_user_i,

    input wire                              core_axi_ar_ready_i,
    output wire                              core_axi_ar_valid_o,
    output wire [AXI_ADDR_WIDTH-1:0]         core_axi_ar_addr_o,
    output wire [2:0]                        core_axi_ar_prot_o,
    output wire [AXI_ID_WIDTH-1:0]           core_axi_ar_id_o,
    output wire [AXI_USER_WIDTH-1:0]         core_axi_ar_user_o,
    output wire [7:0]                        core_axi_ar_len_o,
    output wire [2:0]                        core_axi_ar_size_o,
    output wire [1:0]                        core_axi_ar_burst_o,
    output wire                              core_axi_ar_lock_o,
    output wire [3:0]                        core_axi_ar_cache_o,
    output wire [3:0]                        core_axi_ar_qos_o,
    output wire [3:0]                        core_axi_ar_region_o,

    output wire                              core_axi_r_ready_o,
    input wire                              core_axi_r_valid_i,
    input wire [1:0]                        core_axi_r_resp_i,
    input wire [AXI_DATA_WIDTH-1:0]         core_axi_r_data_i,
    input wire                              core_axi_r_last_i,
    input wire [AXI_ID_WIDTH-1:0]           core_axi_r_id_i,
    input wire [AXI_USER_WIDTH-1:0]         core_axi_r_user_i,

    output wire [63:0]  debug_wb_pc,
    output wire [7:0]   debug_wb_rf_we,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [63:0]  debug_wb_rf_wdata
);

    wire         inst_sram_en;
    wire [7:0]   inst_sram_we;
    wire [63:0]  inst_sram_addr;
    wire [63:0]  inst_sram_wdata;
    wire [63:0]  inst_sram_rdata;

    wire         data_sram_en;
    wire [7:0]   data_sram_we;
    wire [63:0]  data_sram_addr;
    wire [63:0]  data_sram_wdata;
    wire [63:0]  data_sram_rdata;

    // //cpu inst sram
    // wire        cpu_inst_en;
    // wire [7 :0] cpu_inst_wen;
    // wire [63:0] cpu_inst_addr;
    // wire [63:0] cpu_inst_wdata;
    // wire [63:0] cpu_inst_rdata;
    //cpu data sram
    wire        cpu_data_en;
    wire [7 :0] cpu_data_we;
    wire [63:0] cpu_data_addr;
    wire [63:0] cpu_data_wdata;
    wire [63:0] cpu_data_rdata;
    // // data sram 
    // wire        data_sram_en;
    // wire [7 :0] data_sram_wen;
    // wire [63:0] data_sram_addr;
    // wire [63:0] data_sram_wdata;
    // wire [63:0] data_sram_rdata;
    // confreg 
    wire        conf_en;
    wire [7 :0] conf_wen;
    wire [63:0] conf_addr;
    wire [63:0] conf_wdata;
    wire [63:0] conf_rdata;

    wire stallreq_axi;

    mycpu_pipeline 
    #(
        .ID2EX_WD  (`ID2EX_WD  ),
        .EX2MEM_WD (`EX2MEM_WD ),
        .MEM2WB_WD (`MEM2WB_WD ),
        .WB2RF_WD  (`WB2RF_WD  ),
        .MEM2EX_WD (`MEM2EX_WD ),
        .WB2EX_WD  (`WB2EX_WD  )
    )
    u_mycpu_pipeline(
    	.clk               (clk               ),
        .rst_n             (rst_n             ),
        .stallreq_axi      (stallreq_axi      ),

        .inst_sram_en      (inst_sram_en      ),
        .inst_sram_we      (inst_sram_we      ),
        .inst_sram_addr    (inst_sram_addr    ),
        .inst_sram_wdata   (inst_sram_wdata   ),
        .inst_sram_rdata   (inst_sram_rdata   ),

        .data_sram_en      (cpu_data_en      ),
        .data_sram_we      (cpu_data_we      ),
        .data_sram_addr    (cpu_data_addr    ),
        .data_sram_wdata   (cpu_data_wdata   ),
        .data_sram_rdata   (cpu_data_rdata   ),

        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_we    (debug_wb_rf_we    ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    bridge_1x2 u_bridge_1x2(
    .clk             (clk             ),
    .resetn          (resetn          ),
    .cpu_data_en     (cpu_data_en     ),
    .cpu_data_wen    (cpu_data_we     ),
    .cpu_data_addr   (cpu_data_addr   ),
    .cpu_data_wdata  (cpu_data_wdata  ),
    .cpu_data_rdata  (cpu_data_rdata  ),
    .data_sram_en    (data_sram_en    ),
    .data_sram_wen   (data_sram_we    ),
    .data_sram_addr  (data_sram_addr  ),
    .data_sram_wdata (data_sram_wdata ),
    .data_sram_rdata (data_sram_rdata ),
    .conf_en         (conf_en         ),
    .conf_wen        (conf_wen        ),
    .conf_addr       (conf_addr       ),
    .conf_wdata      (conf_wdata      ),
    .conf_rdata      (conf_rdata      )
    );


    confreg 
    #(
        .SIMULATION (1'b1 )
    )
    u_confreg(
        .clk         (cpu_clk     ),
        .timer_clk   (cpu_clk     ),
        .resetn      (cpu_resetn  ),
        .conf_en     (conf_en & ~stallreq_axi),
        .conf_wen    (conf_wen    ),
        .conf_addr   (conf_addr   ),
        .conf_wdata  (conf_wdata  ),
        .conf_rdata  (conf_rdata  )
    );

    axi_ctrl 
    #(
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH ),
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH ),
        .AXI_ID_WIDTH   (AXI_ID_WIDTH   ),
        .AXI_USER_WIDTH (AXI_USER_WIDTH )
    )
    u_axi_ctrl(
    	.clk                  (clk                  ),
        .rst_n                (rst_n                ),
        .stallreq_axi         (stallreq_axi         ),

        .inst_sram_en         (inst_sram_en         ),
        .inst_sram_we         (inst_sram_we         ),
        .inst_sram_addr       (inst_sram_addr       ),
        .inst_sram_wdata      (inst_sram_wdata      ),
        .inst_sram_rdata      (inst_sram_rdata      ),
        .data_sram_en         (data_sram_en         ),
        .data_sram_we         (data_sram_we         ),
        .data_sram_addr       (data_sram_addr       ),
        .data_sram_wdata      (data_sram_wdata      ),
        .data_sram_rdata      (data_sram_rdata      ),

        .core_axi_aw_ready_i  (core_axi_aw_ready_i  ),
        .core_axi_aw_valid_o  (core_axi_aw_valid_o  ),
        .core_axi_aw_addr_o   (core_axi_aw_addr_o   ),
        .core_axi_aw_prot_o   (core_axi_aw_prot_o   ),
        .core_axi_aw_id_o     (core_axi_aw_id_o     ),
        .core_axi_aw_user_o   (core_axi_aw_user_o   ),
        .core_axi_aw_len_o    (core_axi_aw_len_o    ),
        .core_axi_aw_size_o   (core_axi_aw_size_o   ),
        .core_axi_aw_burst_o  (core_axi_aw_burst_o  ),
        .core_axi_aw_lock_o   (core_axi_aw_lock_o   ),
        .core_axi_aw_cache_o  (core_axi_aw_cache_o  ),
        .core_axi_aw_qos_o    (core_axi_aw_qos_o    ),
        .core_axi_aw_region_o (core_axi_aw_region_o ),
        .core_axi_w_ready_i   (core_axi_w_ready_i   ),
        .core_axi_w_valid_o   (core_axi_w_valid_o   ),
        .core_axi_w_data_o    (core_axi_w_data_o    ),
        .core_axi_w_strb_o    (core_axi_w_strb_o    ),
        .core_axi_w_last_o    (core_axi_w_last_o    ),
        .core_axi_w_user_o    (core_axi_w_user_o    ),
        .core_axi_b_ready_o   (core_axi_b_ready_o   ),
        .core_axi_b_valid_i   (core_axi_b_valid_i   ),
        .core_axi_b_resp_i    (core_axi_b_resp_i    ),
        .core_axi_b_id_i      (core_axi_b_id_i      ),
        .core_axi_b_user_i    (core_axi_b_user_i    ),
        .core_axi_ar_ready_i  (core_axi_ar_ready_i  ),
        .core_axi_ar_valid_o  (core_axi_ar_valid_o  ),
        .core_axi_ar_addr_o   (core_axi_ar_addr_o   ),
        .core_axi_ar_prot_o   (core_axi_ar_prot_o   ),
        .core_axi_ar_id_o     (core_axi_ar_id_o     ),
        .core_axi_ar_user_o   (core_axi_ar_user_o   ),
        .core_axi_ar_len_o    (core_axi_ar_len_o    ),
        .core_axi_ar_size_o   (core_axi_ar_size_o   ),
        .core_axi_ar_burst_o  (core_axi_ar_burst_o  ),
        .core_axi_ar_lock_o   (core_axi_ar_lock_o   ),
        .core_axi_ar_cache_o  (core_axi_ar_cache_o  ),
        .core_axi_ar_qos_o    (core_axi_ar_qos_o    ),
        .core_axi_ar_region_o (core_axi_ar_region_o ),
        .core_axi_r_ready_o   (core_axi_r_ready_o   ),
        .core_axi_r_valid_i   (core_axi_r_valid_i   ),
        .core_axi_r_resp_i    (core_axi_r_resp_i    ),
        .core_axi_r_data_i    (core_axi_r_data_i    ),
        .core_axi_r_last_i    (core_axi_r_last_i    ),
        .core_axi_r_id_i      (core_axi_r_id_i      ),
        .core_axi_r_user_i    (core_axi_r_user_i    )
    );
    
endmodule
