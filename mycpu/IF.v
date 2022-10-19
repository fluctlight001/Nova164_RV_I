module IF(
    input wire clk,
    input wire rst_n,
    input wire [5:0] stall,

    input wire [32:0] br_bus,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata
);
    reg pc_valid;
    reg [31:0] pc;
    wire [31:0] pc_nxt;

    wire br_e;
    wire [31:0] br_addr;

    assign {
        br_e, br_addr
    } = br_bus;

    always @ (posedge clk) begin
        if (!rst_n) begin
            pc_valid <= 1'b0;
            pc <= 32'h800f_fffc;
        end
        else if (!stall[0]) begin
            pc_valid <= 1'b1;
            pc <= pc_nxt;
        end
    end
    /*有个问题，如果这里设置成800f_fffcH，
    那么复位结束时不是会想存储器访问一次，
    如果这个位置没数据还好，如果存在数据会不会出事情*/
     

    assign pc_nxt = br_e ? br_addr : pc + 4'h4;

    assign inst_sram_en     = br_e ? 1'b0 : 1'b1;
    assign inst_sram_we     = 4'b0;
    assign inst_sram_addr   = pc;//我认为这里应该访问pc_nxt
    assign inst_sram_wdata  = 32'b0;


endmodule
