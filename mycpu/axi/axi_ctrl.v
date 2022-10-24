module axi_ctrl (
    input  wire clk,
    input  wire rst_n,

    input  wire         inst_sram_en,
    input  wire [7:0]   inst_sram_we,
    input  wire [63:0]  inst_sram_addr,
    input  wire [63:0]  inst_sram_wdata,
    output wire [63:0]  inst_sram_rdata,

    input  wire         data_sram_en,
    input  wire [7:0]   data_sram_we,
    input  wire [63:0]  data_sram_addr,
    input  wire [63:0]  data_sram_wdata,
    output wire [63:0]  data_sram_rdata,

    
);
    
endmodule