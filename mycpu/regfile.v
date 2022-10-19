module regfile(
    input wire clk,
    input wire rst_n,
    
    input wire [4:0] rs1,
    output wire [31:0] rdata1,
    input wire [4:0] rs2,
    output wire [31:0] rdata2,

    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata
);
    reg [31:0] rf [31:0];

    always @ (posedge clk) begin
        if (!rst_n) begin
            rf[ 0] <= 32'b0;
            rf[ 1] <= 32'b0;
            rf[ 2] <= 32'b0;
            rf[ 3] <= 32'b0;
            rf[ 4] <= 32'b0;
            rf[ 5] <= 32'b0;
            rf[ 6] <= 32'b0;
            rf[ 7] <= 32'b0;
            rf[ 8] <= 32'b0;
            rf[ 9] <= 32'b0;
            rf[10] <= 32'b0;
            rf[11] <= 32'b0;
            rf[12] <= 32'b0;
            rf[13] <= 32'b0;
            rf[14] <= 32'b0;
            rf[15] <= 32'b0;
            rf[16] <= 32'b0;
            rf[17] <= 32'b0;
            rf[18] <= 32'b0;
            rf[19] <= 32'b0;
            rf[20] <= 32'b0;
            rf[21] <= 32'b0;
            rf[22] <= 32'b0;
            rf[23] <= 32'b0;
            rf[24] <= 32'b0;
            rf[25] <= 32'b0;
            rf[26] <= 32'b0;
            rf[27] <= 32'b0;
            rf[28] <= 32'b0;
            rf[29] <= 32'b0;
            rf[30] <= 32'b0;
            rf[31] <= 32'b0;
        end
        else if (we) begin
            rf[waddr] <= wdata;
        end
    end

    // assign rdata1 = we & (rs1==waddr) ? wdata : |rs1 ? rf[rs1] : 32'b0;
    assign rdata1 = ~(|rs1) ? 32'b0 : we & (rs1==waddr) ? wdata : rf[rs1];
    // assign rdata2 = we & (rs2==waddr) ? wdata : |rs2 ? rf[rs2] : 32'b0;
    assign rdata2 = ~(|rs2) ? 32'b0 : we & (rs2==waddr) ? wdata : rf[rs2];
endmodule