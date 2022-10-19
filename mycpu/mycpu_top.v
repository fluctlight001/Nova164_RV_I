`define ID2EX_WD 300
`define EX2MEM_WD 300
`define MEM2WB_WD 300
`define WB2RF_WD 300
`define MEM2EX_WD 300
`define WB2EX_WD 300
module mycpu_top(
    input  wire clk,
    input  wire rst_n,
    input  wire ext_int,

    output wire         inst_sram_en,
    output wire [3:0]   inst_sram_we,
    output wire [31:0]  inst_sram_addr,
    output wire [31:0]  inst_sram_wdata,
    input  wire [31:0]  inst_sram_rdata,

    output wire         data_sram_en,
    output wire [3:0]   data_sram_we,
    output wire [31:0]  data_sram_addr,
    output wire [31:0]  data_sram_wdata,
    input  wire [31:0]  data_sram_rdata,

    output wire [31:0]  debug_wb_pc,
    output wire [3:0]   debug_wb_rf_we,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [31:0]  debug_wb_rf_wdata
);
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
        .inst_sram_en      (inst_sram_en      ),
        .inst_sram_we      (inst_sram_we      ),
        .inst_sram_addr    (inst_sram_addr    ),
        .inst_sram_wdata   (inst_sram_wdata   ),
        .inst_sram_rdata   (inst_sram_rdata   ),
        .data_sram_en      (data_sram_en      ),
        .data_sram_we      (data_sram_we      ),
        .data_sram_addr    (data_sram_addr    ),
        .data_sram_wdata   (data_sram_wdata   ),
        .data_sram_rdata   (data_sram_rdata   ),
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_we    (debug_wb_rf_we    ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    
endmodule