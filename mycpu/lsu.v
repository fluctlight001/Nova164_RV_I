module lsu(
    input wire [6:0] lsu_op,
    input wire [63:0] rdata1,
    input wire [63:0] rdata2,
    input wire [63:0] imm,

    output wire data_sram_en,
    output wire [7:0] data_sram_we,
    output wire [63:0] data_sram_addr,
    output wire [63:0] data_sram_wdata,

    output wire [7:0] data_ram_sel
);

    wire data_ram_en;
    wire data_ram_we;
    wire [3:0] data_size_sel;
    wire data_unsigned;

    wire [7:0] byte_sel;

    assign {
        data_ram_en, data_ram_we, data_size_sel, data_unsigned
    } = lsu_op;
    
    // decoder_2_4 u_decoder_2_4(
    // 	.in  (data_sram_addr[1:0]),
    //     .out (byte_sel           )
    // );
    decoder_3_8 u_decoder_3_8(
    	.in  (data_sram_addr[2:0]  ),
        .out (byte_sel             )
    );
    

    assign data_ram_sel = data_size_sel[0] ? byte_sel 
                        : data_size_sel[1] ? {{2{byte_sel[6]}},{2{byte_sel[4]}},{2{byte_sel[2]}},{2{byte_sel[0]}}} 
                        : data_size_sel[2] ? {{4{byte_sel[4]}},{4{byte_sel[0]}}}
                        : data_size_sel[3] ? {8{byte_sel[0]}} 
                        : 8'h0;

    assign data_sram_en     = data_ram_en;
    assign data_sram_we    = {8{data_ram_we}} & data_ram_sel;
    assign data_sram_addr   = rdata1 + imm;
    assign data_sram_wdata  = data_size_sel[0] ? {8{rdata2[7:0]}} 
                            : data_size_sel[1] ? {4{rdata2[15:0]}} 
                            : data_size_sel[2] ? {2{rdata2[31:0]}} 
                            : data_size_sel[3] ? rdata2 : 64'b0;


endmodule
