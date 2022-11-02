/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

//*************************************************************************
//   > File Name   : soc_top.v
//   > Description : SoC, included cpu, 2 x 3 bridge,
//                   inst ram, confreg, data ram
// 
//           -------------------------
//           |           cpu         |
//           -------------------------
//         inst|                  | data
//             |                  | 
//             |        ---------------------
//             |        |    1 x 2 bridge   |
//             |        ---------------------
//             |             |            |           
//             |             |            |           
//      -------------   -----------   -----------
//      | inst ram  |   | data ram|   | confreg |
//      -------------   -----------   -----------
//
//   > Author      : LOONGSON
//   > Date        : 2017-08-04
//*************************************************************************

//for simulation:
//1. if define SIMU_USE_PLL = 1, will use clk_pll to generate cpu_clk/timer_clk,
//   and simulation will be very slow.
//2. usually, please define SIMU_USE_PLL=0 to speed up simulation by assign
//   cpu_clk/timer_clk = clk.
//   at this time, cpu_clk/timer_clk frequency are both 100MHz, same as clk.
`define SIMU_USE_PLL 0 //set 0 to speed up simulation

module soc_lite_top 
#(
    parameter SIMULATION        = 1'b0,
    parameter UDIV              = 868,
    parameter AXI_DATA_WIDTH    = 64 ,
    parameter AXI_ADDR_WIDTH    = 32 ,
    parameter AXI_ID_WIDTH      = 4  ,
    parameter AXI_USER_WIDTH    = 1
)
(
    input         resetn, 
    input         clk,

    //------gpio-------
    output [15:0] led,
    output [1 :0] led_rg0,
    output [1 :0] led_rg1,
    output [7 :0] num_csn,
    output [6 :0] num_a_g,
    input  [7 :0] switch, 
    output [3 :0] btn_key_col,
    input  [3 :0] btn_key_row,
    input  [1 :0] btn_step
);
//debug signals
wire [63:0] debug_wb_pc;
wire [7 :0] debug_wb_rf_wen;
wire [4 :0] debug_wb_rf_wnum;
wire [63:0] debug_wb_rf_wdata;

//clk and resetn
wire cpu_clk;
wire timer_clk;
reg cpu_resetn;
always @(posedge cpu_clk)
begin
    cpu_resetn <= resetn;
end
generate if(SIMULATION && `SIMU_USE_PLL==0)
begin: speedup_simulation
    assign cpu_clk   = clk;
    assign timer_clk = clk;
end
else
begin: pll
    clk_pll clk_pll
    (
        .clk_in1 (clk),
        .cpu_clk (cpu_clk),
        .timer_clk (timer_clk)
    );
end
endgenerate

// //cpu inst sram
// wire        cpu_inst_en;
// wire [7 :0] cpu_inst_wen;
// wire [63:0] cpu_inst_addr;
// wire [63:0] cpu_inst_wdata;
// wire [63:0] cpu_inst_rdata;
// //cpu data sram
// wire        cpu_data_en;
// wire [7 :0] cpu_data_wen;
// wire [63:0] cpu_data_addr;
// wire [63:0] cpu_data_wdata;
// wire [63:0] cpu_data_rdata;

//*wire
wire                              master_axi_aw_ready   ;
wire                              master_axi_aw_valid   ;
wire [AXI_ADDR_WIDTH-1:0]         master_axi_aw_addr    ;
wire [2:0]                        master_axi_aw_prot    ;
wire [AXI_ID_WIDTH-1:0]           master_axi_aw_id      ;
wire [AXI_USER_WIDTH-1:0]         master_axi_aw_user    ;
wire [7:0]                        master_axi_aw_len     ;
wire [2:0]                        master_axi_aw_size    ;
wire [1:0]                        master_axi_aw_burst   ;
wire                              master_axi_aw_lock    ;
wire [3:0]                        master_axi_aw_cache   ;
wire [3:0]                        master_axi_aw_qos     ;
wire [3:0]                        master_axi_aw_region  ;

wire                              master_axi_w_ready    ;
wire                              master_axi_w_valid    ;
wire [AXI_DATA_WIDTH-1:0]         master_axi_w_data     ;
wire [AXI_DATA_WIDTH/8-1:0]       master_axi_w_strb     ;
wire                              master_axi_w_last     ;
wire [AXI_USER_WIDTH-1:0]         master_axi_w_user     ;

wire                              master_axi_b_ready    ;
wire                              master_axi_b_valid    ;
wire [1:0]                        master_axi_b_resp     ;
wire [AXI_ID_WIDTH-1:0]           master_axi_b_id       ;
wire [AXI_USER_WIDTH-1:0]         master_axi_b_user     ;

wire                              master_axi_ar_ready   ;
wire                              master_axi_ar_valid   ;
wire [AXI_ADDR_WIDTH-1:0]         master_axi_ar_addr    ;
wire [2:0]                        master_axi_ar_prot    ;
wire [AXI_ID_WIDTH-1:0]           master_axi_ar_id      ;
wire [AXI_USER_WIDTH-1:0]         master_axi_ar_user    ;
wire [7:0]                        master_axi_ar_len     ;
wire [2:0]                        master_axi_ar_size    ;
wire [1:0]                        master_axi_ar_burst   ;
wire                              master_axi_ar_lock    ;
wire [3:0]                        master_axi_ar_cache   ;
wire [3:0]                        master_axi_ar_qos     ;
wire [3:0]                        master_axi_ar_region  ;

wire                              master_axi_r_ready    ;
wire                              master_axi_r_valid    ;
wire [1:0]                        master_axi_r_resp     ;
wire [AXI_DATA_WIDTH-1:0]         master_axi_r_data     ;
wire                              master_axi_r_last     ;
wire [AXI_ID_WIDTH-1:0]           master_axi_r_id       ;
wire [AXI_USER_WIDTH-1:0]         master_axi_r_user     ;


//cpu
mycpu_top
#(
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH ),
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH ),
    .AXI_ID_WIDTH   (AXI_ID_WIDTH   ),
    .AXI_USER_WIDTH (AXI_USER_WIDTH )
) 
cpu(
    .clk              (cpu_clk   ),
    .rst_n            (cpu_resetn),  //low active
    .ext_int          (6'd0      ),  //interrupt,high active

    .core_axi_aw_ready_i        (master_axi_aw_ready  ),
    .core_axi_aw_valid_o        (master_axi_aw_valid  ),
    .core_axi_aw_addr_o         (master_axi_aw_addr   ),
    .core_axi_aw_prot_o         (master_axi_aw_prot   ),
    .core_axi_aw_id_o           (master_axi_aw_id     ),
    .core_axi_aw_user_o         (master_axi_aw_user   ),
    .core_axi_aw_len_o          (master_axi_aw_len    ),
    .core_axi_aw_size_o         (master_axi_aw_size   ),
    .core_axi_aw_burst_o        (master_axi_aw_burst  ),
    .core_axi_aw_lock_o         (master_axi_aw_lock   ),
    .core_axi_aw_cache_o        (master_axi_aw_cache  ),
    .core_axi_aw_qos_o          (master_axi_aw_qos    ),
    .core_axi_aw_region_o       (master_axi_aw_region ),

    .core_axi_w_ready_i         (master_axi_w_ready   ),
    .core_axi_w_valid_o         (master_axi_w_valid   ),
    .core_axi_w_data_o          (master_axi_w_data    ),
    .core_axi_w_strb_o          (master_axi_w_strb    ),
    .core_axi_w_last_o          (master_axi_w_last    ),
    .core_axi_w_user_o          (master_axi_w_user    ),

    .core_axi_b_ready_o         (master_axi_b_ready   ),
    .core_axi_b_valid_i         (master_axi_b_valid   ),
    .core_axi_b_resp_i          (master_axi_b_resp    ),
    .core_axi_b_id_i            (master_axi_b_id      ),
    .core_axi_b_user_i          (master_axi_b_user    ),

    .core_axi_ar_ready_i        (master_axi_ar_ready ),
    .core_axi_ar_valid_o        (master_axi_ar_valid ),
    .core_axi_ar_addr_o         (master_axi_ar_addr  ),
    .core_axi_ar_prot_o         (master_axi_ar_prot  ),
    .core_axi_ar_id_o           (master_axi_ar_id    ),
    .core_axi_ar_user_o         (master_axi_ar_user  ),
    .core_axi_ar_len_o          (master_axi_ar_len   ),
    .core_axi_ar_size_o         (master_axi_ar_size  ),
    .core_axi_ar_burst_o        (master_axi_ar_burst ),
    .core_axi_ar_lock_o         (master_axi_ar_lock  ),
    .core_axi_ar_cache_o        (master_axi_ar_cache ),
    .core_axi_ar_qos_o          (master_axi_ar_qos   ),
    .core_axi_ar_region_o       (master_axi_ar_region),

    .core_axi_r_ready_o         (master_axi_r_ready  ),
    .core_axi_r_valid_i         (master_axi_r_valid  ),
    .core_axi_r_resp_i          (master_axi_r_resp   ),
    .core_axi_r_data_i          (master_axi_r_data   ),
    .core_axi_r_last_i          (master_axi_r_last   ),
    .core_axi_r_id_i            (master_axi_r_id     ),
    .core_axi_r_user_i          (master_axi_r_user   ),

    //debug
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_we   (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

// //inst ram
// bdram_64 inst_ram
// (
//     .clka  (cpu_clk            ),   
//     .ena   (cpu_inst_en        ),
//     .wea   (cpu_inst_wen       ),   //7:0
//     .addra (cpu_inst_addr[16:3]),   //17:0
//     .dina  (cpu_inst_wdata     ),   //63:0
//     .douta (cpu_inst_rdata     )    //63:0
// );

// //data ram
// bdram_64 data_ram
// (
//     .clka  (cpu_clk            ),   
//     .ena   (cpu_data_en        ),
//     .wea   (cpu_data_wen       ),   //7:0
//     .addra (cpu_data_addr[16:3]),   //15:0
//     .dina  (cpu_data_wdata     ),   //63:0
//     .douta (cpu_data_rdata     )    //63:0
// );

axi4_slave 
#(
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH ),
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH ),
    .AXI_ID_WIDTH   (AXI_ID_WIDTH   ),
    .AXI_USER_WIDTH (AXI_USER_WIDTH )
)
u_axi4_slave(
    .AXI_ACLK        (cpu_clk        ),
    .AXI_ARESETN     (cpu_resetn     ),
    .AXI_AW_ID_I     (master_axi_aw_id     ),
    .AXI_AW_ADDR_I   (master_axi_aw_addr   ),
    .AXI_AW_LEN_I    (master_axi_aw_len    ),
    .AXI_AW_SIZE_I   (master_axi_aw_size   ),
    .AXI_AW_BURST_I  (master_axi_aw_burst  ),
    .AXI_AW_LOCK_I   (master_axi_aw_lock   ),
    .AXI_AW_CACHE_I  (master_axi_aw_cache  ),
    .AXI_AW_PROT_I   (master_axi_aw_prot   ),
    .AXI_AW_QOS_I    (master_axi_aw_qos    ),
    .AXI_AW_REGION_I (master_axi_aw_region ),
    .AXI_AW_USER_I   (master_axi_aw_user   ),
    .AXI_AW_VALID_I  (master_axi_aw_valid  ),
    .AXI_AW_READY_O  (master_axi_aw_ready  ),

    .AXI_W_ID_I      (0      ),
    .AXI_W_DATA_I    (master_axi_w_data    ),
    .AXI_W_STRB_I    (master_axi_w_strb    ),
    .AXI_W_LAST_I    (master_axi_w_last    ),
    .AXI_W_USER_I    (master_axi_w_user    ),
    .AXI_W_VALID_I   (master_axi_w_valid   ),
    .AXI_W_READY_O   (master_axi_w_ready   ),

    .AXI_B_ID_O      (master_axi_b_id      ),
    .AXI_B_RESP_O    (master_axi_b_resp    ),
    .AXI_B_USER_O    (master_axi_b_user    ),
    .AXI_B_VALID_O   (master_axi_b_valid   ),
    .AXI_B_READY_I   (master_axi_b_ready   ),

    .AXI_AR_ID_I     (master_axi_ar_id     ),
    .AXI_AR_ADDR_I   (master_axi_ar_addr   ),
    .AXI_AR_LEN_I    (master_axi_ar_len    ),
    .AXI_AR_SIZE_I   (master_axi_ar_size   ),
    .AXI_AR_BURST_I  (master_axi_ar_burst  ),
    .AXI_AR_LOCK_I   (master_axi_ar_lock   ),
    .AXI_AR_CACHE_I  (master_axi_ar_cache  ),
    .AXI_AR_PROT_I   (master_axi_ar_prot   ),
    .AXI_AR_QOS_I    (master_axi_ar_qos    ),
    .AXI_AR_REGION_I (master_axi_ar_region ),
    .AXI_AR_USER_I   (master_axi_ar_user   ),
    .AXI_AR_VALID_I  (master_axi_ar_valid  ),
    .AXI_AR_READY_O  (master_axi_ar_ready  ),
    
    .AXI_R_ID_O      (master_axi_r_id      ),
    .AXI_R_DATA_O    (master_axi_r_data    ),
    .AXI_R_RESP_O    (master_axi_r_resp    ),
    .AXI_R_LAST_O    (master_axi_r_last    ),
    .AXI_R_USER_O    (master_axi_r_user    ),
    .AXI_R_VALID_O   (master_axi_r_valid   ),
    .AXI_R_READY_I   (master_axi_r_ready   )
);



endmodule

