module WB
#(
    parameter MEM2WB_WD = 50,
    parameter WB2RF_WD = 50,
    parameter WB2EX_WD = 50
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [5:0] stall,

    input  wire [MEM2WB_WD-1:0] mem2wb_bus,
    output wire [WB2RF_WD-1:0] wb2rf_bus,
    output wire [WB2EX_WD-1:0] wb2ex_fwd,

    output wire [63:0]  debug_wb_pc,
    output wire [7:0]   debug_wb_rf_we,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [63:0]  debug_wb_rf_wdata
);

    reg [MEM2WB_WD-1:0] mem2wb_bus_r;
    always @ (posedge clk) begin
        if (!rst_n) begin
            mem2wb_bus_r <= 0;
        end
        else if (stall[4]&(!stall[5])) begin
            mem2wb_bus_r <= 0;
        end
        else if (!stall[4]) begin
            mem2wb_bus_r <= mem2wb_bus;
        end
    end
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [63:0] rf_wdata;
    wire [63:0] pc;
    wire [31:0] inst;

    assign {
        rf_we,
        rf_waddr,
        rf_wdata,
        pc,
        inst
    } = mem2wb_bus_r;

    assign wb2rf_bus = {
        rf_we,
        rf_waddr,
        rf_wdata
    };

    assign wb2ex_fwd = wb2rf_bus;

    assign debug_wb_pc = pc;
    assign debug_wb_rf_we = {8{rf_we}};
    assign debug_wb_rf_wnum = rf_waddr;
    assign debug_wb_rf_wdata = rf_wdata;
endmodule