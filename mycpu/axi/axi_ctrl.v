module axi_ctrl #(
  parameter AXI_DATA_WIDTH = 64,
  parameter AXI_ADDR_WIDTH = 32,
  parameter AXI_ID_WIDTH = 4,
  parameter AXI_USER_WIDTH = 1
)(
    input  wire clk,
    input  wire rst_n,
    output reg  stallreq_axi,

    input  wire         inst_sram_en,
    input  wire [7:0]   inst_sram_we,
    input  wire [63:0]  inst_sram_addr,
    input  wire [63:0]  inst_sram_wdata,
    output reg  [63:0]  inst_sram_rdata,

    input  wire         data_sram_en,
    input  wire [7:0]   data_sram_we,
    input  wire [63:0]  data_sram_addr,
    input  wire [63:0]  data_sram_wdata,
    output reg  [63:0]  data_sram_rdata,

    input wire                              core_axi_aw_ready_i,
    output reg                              core_axi_aw_valid_o,
    output reg [AXI_ADDR_WIDTH - 1:0]       core_axi_aw_addr_o,
    output reg [2:0]                        core_axi_aw_prot_o,
    output reg [AXI_ID_WIDTH-1:0]           core_axi_aw_id_o,
    output reg [AXI_USER_WIDTH-1:0]         core_axi_aw_user_o,
    output reg [7:0]                        core_axi_aw_len_o,
    output reg [2:0]                        core_axi_aw_size_o,
    output reg [1:0]                        core_axi_aw_burst_o,
    output reg                              core_axi_aw_lock_o,
    output reg [3:0]                        core_axi_aw_cache_o,
    output reg [3:0]                        core_axi_aw_qos_o,
    output reg [3:0]                        core_axi_aw_region_o,

    input wire                              core_axi_w_ready_i,
    output reg                              core_axi_w_valid_o,
    output reg [AXI_DATA_WIDTH-1:0]         core_axi_w_data_o,
    output reg [AXI_DATA_WIDTH/8-1:0]       core_axi_w_strb_o,
    output reg                              core_axi_w_last_o,
    output reg [AXI_USER_WIDTH-1:0]         core_axi_w_user_o,

    output reg                              core_axi_b_ready_o,
    input wire                              core_axi_b_valid_i,
    input wire [1:0]                        core_axi_b_resp_i,
    input wire [AXI_ID_WIDTH-1:0]           core_axi_b_id_i,
    input wire [AXI_USER_WIDTH-1:0]         core_axi_b_user_i,

    input wire                              core_axi_ar_ready_i,
    output reg                              core_axi_ar_valid_o,
    output reg [AXI_ADDR_WIDTH-1:0]         core_axi_ar_addr_o,
    output reg [2:0]                        core_axi_ar_prot_o,
    output reg [AXI_ID_WIDTH-1:0]           core_axi_ar_id_o,
    output reg [AXI_USER_WIDTH-1:0]         core_axi_ar_user_o,
    output reg [7:0]                        core_axi_ar_len_o,
    output reg [2:0]                        core_axi_ar_size_o,
    output reg [1:0]                        core_axi_ar_burst_o,
    output reg                              core_axi_ar_lock_o,
    output reg [3:0]                        core_axi_ar_cache_o,
    output reg [3:0]                        core_axi_ar_qos_o,
    output reg [3:0]                        core_axi_ar_region_o,

    output reg                              core_axi_r_ready_o,
    input wire                              core_axi_r_valid_i,
    input wire [1:0]                        core_axi_r_resp_i,
    input wire [AXI_DATA_WIDTH-1:0]         core_axi_r_data_i,
    input wire                              core_axi_r_last_i,
    input wire [AXI_ID_WIDTH-1:0]           core_axi_r_id_i,
    input wire [AXI_USER_WIDTH-1:0]         core_axi_r_user_i
);
    reg [11:0] state;
    always @ (posedge clk) begin
        if (!rst_n) begin
            core_axi_aw_valid_o <= 0;
            core_axi_aw_addr_o <= 0;
            core_axi_aw_prot_o <= 0;
            core_axi_aw_id_o <= 0;
            core_axi_aw_user_o <= 0;
            core_axi_aw_burst_o <= 0;
            core_axi_aw_lock_o <= 0;
            core_axi_aw_cache_o <= 0;
            core_axi_aw_qos_o <= 0;
            core_axi_aw_region_o <= 0;

            core_axi_w_valid_o <= 0;
            core_axi_w_data_o <= 0;
            core_axi_w_strb_o <= 0;
            core_axi_w_last_o <= 0;
            core_axi_w_user_o <= 0;

            core_axi_b_ready_o <= 0;

            core_axi_ar_valid_o <= 0;
            core_axi_ar_addr_o <= 0;
            core_axi_ar_prot_o <= 0;
            core_axi_ar_id_o <= 0;
            core_axi_ar_user_o <= 0;
            core_axi_ar_len_o <= 0;
            core_axi_ar_size_o <= 0;
            core_axi_ar_burst_o <= 0;
            core_axi_ar_lock_o <= 0;
            core_axi_ar_cache_o <= 0;
            core_axi_ar_qos_o <= 0;
            core_axi_ar_region_o <= 0;

            core_axi_r_ready_o <= 0;

            state <= 0;
            stallreq_axi <= 1'b1;
        end
        else begin
            case(1'b1)
                state[0]:begin
                    stallreq_axi <= 1'b1;
                    state <= state << 1;
                end
                state[1]:begin
                    if (inst_sram_en & ~(|inst_sram_we)) begin
                        core_axi_ar_valid_o <= 1'b1;
                        core_axi_ar_addr_o <= {inst_sram_addr[31:3],3'b0};
                        core_axi_ar_id_o <= 1;
                        core_axi_ar_len_o <= 0;
                        core_axi_ar_size_o <= 3'b111;
                        core_axi_ar_burst_o <= 0;
                        state <= state << 1;
                    end
                    else if (data_sram_en & ~(|data_sram_we)) begin
                        core_axi_ar_valid_o <= 1'b1;
                        core_axi_ar_addr_o <= {data_sram_addr[31:3],3'b0};
                        core_axi_ar_id_o <= 2;
                        core_axi_ar_len_o <= 0;
                        core_axi_ar_size_o <= 3'b111;
                        core_axi_ar_burst_o <= 0;
                        state <= state << 4;
                    end
                    else if (data_sram_en & (|data_sram_we)) begin
                        core_axi_aw_valid_o <= 1'b1;
                        core_axi_aw_addr_o <= {data_sram_addr[31:3],3'b0};
                        core_axi_aw_id_o <= 3;
                        core_axi_aw_len_o <= 0;
                        core_axi_aw_size_o <= 3'b111;
                        core_axi_aw_burst_o <= 0;

                        core_axi_w_valid_o <= 1'b1;
                        core_axi_w_data_o <= data_sram_wdata;
                        core_axi_w_strb_o <= data_sram_we;
                        core_axi_w_last_o <= 1'b1;
                        state <= state << 6;
                    end
                    else begin
                        state <= 0;
                    end
                end
                state[2]:begin
                    if (core_axi_ar_ready_i) begin
                        core_axi_ar_valid_o <= 1'b0;
                        state <= state << 1;
                    end
                end
                state[3]: begin
                    if (core_axi_r_valid_i & core_axi_r_last_i) begin
                        core_axi_r_ready_o <= 1'b1;
                        inst_sram_rdata <= core_axi_r_data_i;
                        state <= state << 1;
                    end
                end
                state[4]:begin
                    if (data_sram_en & ~(|data_sram_we)) begin
                        core_axi_ar_valid_o <= 1'b1;
                        core_axi_ar_addr_o <= {data_sram_addr[31:3],3'b0};
                        core_axi_ar_id_o <= 2;
                        core_axi_ar_len_o <= 0;
                        core_axi_ar_size_o <= 3'b111;
                        core_axi_ar_burst_o <= 0;
                        state <= state << 1;
                    end
                    else if (data_sram_en & (|data_sram_we)) begin
                        core_axi_aw_valid_o <= 1'b1;
                        core_axi_aw_addr_o <= {data_sram_addr[31:3],3'b0};
                        core_axi_aw_id_o <= 3;
                        core_axi_aw_len_o <= 0;
                        core_axi_aw_size_o <= 3'b111;
                        core_axi_aw_burst_o <= 0;

                        core_axi_w_valid_o <= 1'b1;
                        core_axi_w_data_o <= data_sram_wdata;
                        core_axi_w_strb_o <= data_sram_we;
                        core_axi_w_last_o <= 1'b1;
                        state <= state << 3;
                    end
                    else begin
                        state <= 0;
                    end
                end
                state[5]:begin
                    if (core_axi_ar_ready_i) begin
                        core_axi_ar_valid_o <= 1'b0;
                        state <= state << 1;
                    end
                end
                state[6]:begin
                    if (core_axi_r_valid_i & core_axi_r_last_i) begin
                        core_axi_r_ready_o <= 1'b1;
                        data_sram_rdata <= core_axi_r_data_i;
                        state <= 0;
                    end
                end
                state[7]:begin
                    if (core_axi_aw_ready_i) begin
                        core_axi_aw_valid_o <= 1'b0;
                    end
                    if (core_axi_w_ready_i) begin
                        core_axi_w_valid_o <= 1'b0;
                    end
                    if (!core_axi_aw_valid_o & !core_axi_w_valid_o) begin
                        state <= state << 1;
                    end
                end
                state[8]:begin
                    if (core_axi_b_valid_i) begin
                        core_axi_b_ready_o <= 1'b1;
                        state <= 0;
                    end
                end
                default:begin
                    state <= 1'b1;
                    stallreq_axi <= 1'b0;
                    core_axi_r_ready_o <= 1'b0;
                    core_axi_b_ready_o <= 1'b0;
                end
            endcase
        end
    end
endmodule