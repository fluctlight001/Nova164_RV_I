module IF(
    input wire clk,
    input wire rst_n,
    input wire [5:0] stall,

    input wire [64:0] br_bus,

    output wire inst_sram_en,
    output wire [7:0] inst_sram_we,
    output wire [63:0] inst_sram_addr,
    output wire [63:0] inst_sram_wdata
);
    reg pc_valid;
    reg [63:0] pc;
    wire [63:0] pc_nxt;

    wire br_e;
    wire [63:0] br_addr;

    assign {
        br_e, br_addr
    } = br_bus;

    always @ (posedge clk) begin
        if (!rst_n) begin
            pc_valid <= 1'b0;
            pc <= 64'h7fff_fffc;
        end
        else if (!stall[0]) begin
            pc_valid <= 1'b1;
            pc <= pc_nxt;
        end
        /* if (stall[0] & stall[1]) begin  */
        /*   pc_valid <= 1'b0; */
        /*   pc <= 0; */
        /* end */
    end

    assign pc_nxt = br_e ? br_addr : pc + 4'h4;

    assign inst_sram_en     = br_e ? 1'b0 : pc_valid ;
    assign inst_sram_we     = 8'b0;
    assign inst_sram_addr   = pc;//我认为这里应该访问pc_nxt
    assign inst_sram_wdata  = 64'b0;


endmodule
