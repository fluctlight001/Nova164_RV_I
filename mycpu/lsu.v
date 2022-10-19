module lsu(
    input wire [5:0] lsu_op,
    input wire [31:0] rdata1,
    input wire [31:0] rdata2,
    input wire [31:0] imm,

    output wire data_sram_en,
    output wire [3:0] data_sram_we,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,

    output wire [3:0] data_ram_sel
);

    wire data_ram_en;
    wire data_ram_we;
    wire [2:0] data_size_sel;
    wire data_unsigned;

    wire [3:0] byte_sel;

    assign {
        data_ram_en, data_ram_we, data_size_sel, data_unsigned
    } = lsu_op;
    
    decoder_2_4 u_decoder_2_4(
    	.in  (data_sram_addr[1:0]),
        .out (byte_sel           )
    );
    
    assign data_ram_sel =   data_size_sel[0] ? byte_sel :
                            data_size_sel[1] ? {{2{byte_sel[2]}},{2{byte_sel[0]}}} :
                            data_size_sel[2] ? 4'b1111 : 4'b0000;

    assign data_sram_en     = data_ram_en;
    assign data_sram_we    = {4{data_ram_we}} & data_ram_sel;
    assign data_sram_addr   = rdata1 + imm;
    assign data_sram_wdata  =  data_size_sel[0] ? {4{rdata2[7:0]}} :
                               data_size_sel[1] ? {2{rdata2[15:0]}} :
                               data_size_sel[2] ? rdata2 : 32'b0;


endmodule
