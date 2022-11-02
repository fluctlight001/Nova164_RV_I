module frv_bdram_64 (
input                     clk,
//input   [15:0]            addra,
//output  reg[63:0]         douta,

input   [15:0]            addr,
input   [63:0]            din,
input   [7:0]             wen,
output  reg[63:0]         dout
);

parameter  MEMDEPTH = 2**(16);
wire [63:0] inst_read;

reg [63:0] mem [(MEMDEPTH-1):0] /* synthesis syn_ramstyle = "no_rw_check" */;

// initial begin
//   $readmemh("E:/develop/frv232platform/tb/riscvtest/fib-riscv32-nemu.bin.data",_frv_bdram_32.mem);
// end

wire[7:0] mem_0 = mem[addr][7:0];
wire[7:0] mem_1 = mem[addr][15:8];
wire[7:0] mem_2 = mem[addr][23:16];
wire[7:0] mem_3 = mem[addr][31:24];
wire[7:0] mem_4 = mem[addr][39:32];
wire[7:0] mem_5 = mem[addr][47:40];
wire[7:0] mem_6 = mem[addr][55:48];
wire[7:0] mem_7 = mem[addr][63:56];

wire[7:0] memw_0 = wen[0] ? din[7:0]    : mem_0;
wire[7:0] memw_1 = wen[1] ? din[15:8]   : mem_1;
wire[7:0] memw_2 = wen[2] ? din[23:16]  : mem_2;
wire[7:0] memw_3 = wen[3] ? din[31:24]  : mem_3;
wire[7:0] memw_4 = wen[4] ? din[39:32]  : mem_4;
wire[7:0] memw_5 = wen[5] ? din[47:40]  : mem_5;
wire[7:0] memw_6 = wen[6] ? din[55:48]  : mem_6;
wire[7:0] memw_7 = wen[7] ? din[63:56]  : mem_7;

wire [63:0] memw_data = {memw_7, memw_6, memw_5, memw_4, memw_3, memw_2, memw_1, memw_0};

// wire TEST_JUDGE = mem[16'h008b] == 32'h0984_0913;

//assign inst_read = mem[addra];

always @(posedge !clk)
begin
  if(|wen)
  begin
    mem[addr]       <= memw_data;
    dout            <= din;
    //douta           <= inst_read;
  end
  else
  begin
    dout            <= mem[addr];
    //douta           <= inst_read;
  end
end
endmodule
