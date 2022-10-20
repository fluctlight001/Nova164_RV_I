module MEM 
#(
    parameter EX2MEM_WD = 50,
    parameter MEM2WB_WD = 50,
    parameter MEM2EX_WD = 50
)(
    input wire clk,
    input wire rst_n,
    input wire [5:0] stall,

    input wire [EX2MEM_WD-1:0] ex2mem_bus,
    output wire [MEM2WB_WD-1:0] mem2wb_bus,
    output wire [MEM2EX_WD-1:0] mem2ex_fwd,

    input wire [63:0] data_sram_rdata
);
    
    reg [EX2MEM_WD-1:0] ex2mem_bus_r;
    always @ (posedge clk) begin
        if (!rst_n) begin
            ex2mem_bus_r <= 0;
        end
        else if (stall[3]&(!stall[4])) begin
            ex2mem_bus_r <= 0;
        end
        else if (!stall[3]) begin
            ex2mem_bus_r <= ex2mem_bus;
        end
    end

    wire [6:0] lsu_op;
    wire data_ram_en;
    wire data_ram_we;
    wire [3:0] data_size_sel;
    wire data_unsigned;
    wire [7:0] data_ram_sel;
    wire sel_rf_res;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [63:0] ex_result;
    wire [63:0] pc;
    wire [31:0] inst;

    assign {
        lsu_op,
        data_ram_sel,
        sel_rf_res,
        rf_we,
        rf_waddr,
        ex_result,
        pc,
        inst
    } = ex2mem_bus_r;

    assign {
        data_ram_en, data_ram_we, data_size_sel, data_unsigned
    } = lsu_op;

    wire [63:0] mem_result;
    wire [63:0] rf_wdata;

    wire [7:0] b_data;
    wire [15:0] h_data;
    wire [31:0] w_data;
    wire [63:0] d_data;

    assign b_data = data_ram_sel[7] ? data_sram_rdata[63:56] :
                    data_ram_sel[6] ? data_sram_rdata[55:48] :
                    data_ram_sel[5] ? data_sram_rdata[47:40] :
                    data_ram_sel[4] ? data_sram_rdata[39:32] :
                    data_ram_sel[3] ? data_sram_rdata[31:24] :
                    data_ram_sel[2] ? data_sram_rdata[23:16] :
                    data_ram_sel[1] ? data_sram_rdata[15: 8] :
                    data_ram_sel[0] ? data_sram_rdata[ 7: 0] : 8'b0;
    assign h_data = data_ram_sel[6] ? data_sram_rdata[63:48] :
                    data_ram_sel[4] ? data_sram_rdata[47: 0] :
                    data_ram_sel[2] ? data_sram_rdata[31:16] :
                    data_ram_sel[0] ? data_sram_rdata[15: 0] : 16'b0;
    assign w_data = data_ram_sel[4] ? data_sram_rdata[63:32] : 
                    data_ram_sel[0] ? data_sram_rdata[31: 0] : 32'b0;
    assign d_data = data_sram_rdata;

    assign mem_result = data_size_sel[0] & data_unsigned ? {56'b0,b_data} :
                        data_size_sel[0] ? {{56{b_data[7]}},b_data} :
                        data_size_sel[1] & data_unsigned ? {48'b0,h_data} :
                        data_size_sel[1] ? {{48{h_data[15]}},h_data} :
                        data_size_sel[2] & data_unsigned ? {32'b0,w_data} :
                        data_size_sel[2] ? {{32{w_data[31]}},w_data} :
                        data_size_sel[3] ? d_data : 64'b0;
    
    assign rf_wdata = sel_rf_res ? mem_result : ex_result;

    assign mem2wb_bus = {
        rf_we,
        rf_waddr,
        rf_wdata,
        pc,
        inst
    };

    assign mem2ex_fwd = {
        rf_we,
        rf_waddr,
        ex_result
    };
endmodule