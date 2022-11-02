//read processing
`define READ_IDLE   3'b001 
`define READ_MID    3'b010
`define READ_END    3'b100

//write processing
`define WRITE_IDLE  3'b001
`define WRITE_MID   3'b010
`define WRITE_END   3'b100

module axi4_slave #(
  parameter AXI_DATA_WIDTH = 64,
  parameter AXI_ADDR_WIDTH = 32,
  parameter AXI_ID_WIDTH = 4,
  parameter AXI_USER_WIDTH = 1
)(
  input                             AXI_ACLK,
  input                             AXI_ARESETN,

  input [AXI_ID_WIDTH-1:0]          AXI_AW_ID_I,
  input [AXI_ADDR_WIDTH - 1:0]      AXI_AW_ADDR_I,
  input [7:0]                       AXI_AW_LEN_I,
  input [2:0]                       AXI_AW_SIZE_I,
  input [1:0]                       AXI_AW_BURST_I,
  input                             AXI_AW_LOCK_I,
  input [3:0]                       AXI_AW_CACHE_I,
  input [2:0]                       AXI_AW_PROT_I,
  input [3:0]                       AXI_AW_QOS_I,
  input [3:0]                       AXI_AW_REGION_I,
  input [AXI_USER_WIDTH-1:0]        AXI_AW_USER_I,
  input                             AXI_AW_VALID_I,
  output                            AXI_AW_READY_O,

  input [AXI_ID_WIDTH-1:0]          AXI_W_ID_I,
  input [AXI_DATA_WIDTH-1:0]        AXI_W_DATA_I,
  input [AXI_DATA_WIDTH/8-1:0]      AXI_W_STRB_I,
  input                             AXI_W_LAST_I,
  input [AXI_USER_WIDTH-1:0]        AXI_W_USER_I,
  input                             AXI_W_VALID_I,
  output                            AXI_W_READY_O,

  output [AXI_ID_WIDTH-1:0]         AXI_B_ID_O,
  output [1:0]                      AXI_B_RESP_O,
  output [AXI_USER_WIDTH-1:0]       AXI_B_USER_O,
  output                            AXI_B_VALID_O,
  input                             AXI_B_READY_I,

  input [AXI_ID_WIDTH-1:0]          AXI_AR_ID_I,
  input [AXI_ADDR_WIDTH-1:0]        AXI_AR_ADDR_I,
  input [7:0]                       AXI_AR_LEN_I,
  input [2:0]                       AXI_AR_SIZE_I,
  input [1:0]                       AXI_AR_BURST_I,
  input                             AXI_AR_LOCK_I,
  input [3:0]                       AXI_AR_CACHE_I,
  input [2:0]                       AXI_AR_PROT_I,
  input [3:0]                       AXI_AR_QOS_I,
  input [3:0]                       AXI_AR_REGION_I,
  input [AXI_USER_WIDTH-1:0]        AXI_AR_USER_I,
  input                             AXI_AR_VALID_I,
  output                            AXI_AR_READY_O,

  output [AXI_ID_WIDTH-1:0]         AXI_R_ID_O,
  output [AXI_DATA_WIDTH-1:0]       AXI_R_DATA_O,
  output [1:0]                      AXI_R_RESP_O,
  output                            AXI_R_LAST_O,
  output [AXI_USER_WIDTH-1:0]       AXI_R_USER_O,
  output                            AXI_R_VALID_O,
  input                             AXI_R_READY_I
);

wire [63:0] ram_dout;
wire [15:0] ram_addr;
wire [63:0] ram_din;
wire [7:0] ram_wen;

reg [2:0] read_state;
reg [2:0] next_read_state;
reg [63:0] axi_rdata;

// AXI_AR_VALID_I is up, we make the AXI_AR_READY_O up
always @(*) begin 
  next_read_state = `READ_IDLE;
  case (read_state)
    `READ_IDLE: begin 
      next_read_state = AXI_AR_VALID_I ? `READ_MID : `READ_IDLE;
    end
    `READ_MID: begin 
      next_read_state = `READ_END; //握手
    end
    `READ_END: begin 
      next_read_state = AXI_R_READY_I ? `READ_IDLE : `READ_END;
    end
    default: begin end
  endcase
end

always @(negedge AXI_ACLK) begin 
  if(!AXI_ARESETN) begin 
    read_state <= `READ_IDLE;
  end
  else begin
    if(read_state == `READ_MID) begin 
      axi_rdata <= ram_dout;
    end
    read_state <= next_read_state;
  end
end

assign AXI_AR_READY_O = read_state == `READ_MID;
assign AXI_R_VALID_O = read_state == `READ_END;
assign AXI_R_LAST_O = read_state == `READ_END;
assign AXI_R_DATA_O = axi_rdata;

reg [2:0] write_state;
reg [2:0] next_write_state;

//reg [7:0] axi_wen;
//reg [63:0] axi_wdata;
//reg [31:0] axi_waddr;
always @(*) begin 
  next_write_state = `WRITE_IDLE;
  case(write_state) 
    `WRITE_IDLE: begin 
      next_write_state = (AXI_AW_VALID_I && AXI_W_VALID_I) ? `WRITE_MID : `WRITE_IDLE;
    end
    `WRITE_MID: begin 
      next_write_state = `WRITE_END; //握手
    end
    `WRITE_END: begin 
      next_write_state = AXI_B_READY_I ? `WRITE_IDLE : `WRITE_END;
    end
    default: begin end
  endcase
end

always @(negedge AXI_ACLK) begin 
  if(!AXI_ARESETN) begin 
    write_state <= `WRITE_IDLE;
  end
  else 
  begin 
    write_state <= next_write_state;
  end
end

assign AXI_W_READY_O = write_state ==  `WRITE_MID;
assign AXI_AW_READY_O = write_state == `WRITE_MID;
assign AXI_B_VALID_O = write_state ==  `WRITE_END;

assign ram_addr = (write_state == `WRITE_MID) ? AXI_AW_ADDR_I[18:3] : AXI_AR_ADDR_I[18:3];
assign ram_din = AXI_W_DATA_I;
assign ram_wen = (write_state == `WRITE_MID) ? AXI_W_STRB_I : 8'h00;

frv_bdram_64 u_ram(
  .clk(AXI_ACLK),
  .addr(ram_addr),
  .din(ram_din),
  .wen(ram_wen),
  .dout(ram_dout)
);
endmodule
