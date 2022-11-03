/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
`timescale 1ns / 1ps
`define TEST_NAME "add"
`define LINE_NUM 220
`define TRACE_REF_FILE_PRFIX "../../../../../../../cpu132_gettrace/ans/"
`define TRACE_REF_FILE {`TRACE_REF_FILE_PRFIX,`TEST_NAME,"-riscv64-nemu.ans"}
`define SOURCE_FILE {`TRACE_REF_FILE_PRFIX,`TEST_NAME,"-riscv64-nemu.data"}
`define CONFREG_OPEN_TRACE   1'b1
`define END_PC 32'hbfc00100

module tb_top( );
reg resetn;
reg clk;

// initial
// begin
//     clk = 1'b0;
//     resetn = 1'b0;
//     #2000;
//     resetn = 1'b1;
// end
always #5 clk=~clk;
soc_lite_top #(.SIMULATION(1'b1)) soc_lite
(
       .resetn      (resetn     ), 
       .clk         (clk        )
    );   

//soc lite signals
//"soc_clk" means clk in cpu
//"wb" means write-back stage in pipeline
//"rf" means regfiles in cpu
//"w" in "wen/wnum/wdata" means writing
wire soc_clk;
wire [63:0] debug_wb_pc;
wire [7 :0] debug_wb_rf_wen;
wire [4 :0] debug_wb_rf_wnum;
wire [63:0] debug_wb_rf_wdata;
assign soc_clk           = soc_lite.cpu_clk;
assign debug_wb_pc       = soc_lite.debug_wb_pc;
assign debug_wb_rf_wen   = soc_lite.debug_wb_rf_wen;
assign debug_wb_rf_wnum  = soc_lite.debug_wb_rf_wnum;
assign debug_wb_rf_wdata = soc_lite.debug_wb_rf_wdata;

//wdata[i*8+7 : i*8] is valid, only wehile wen[i] is valid
wire [63:0] debug_wb_rf_wdata_v;
assign debug_wb_rf_wdata_v[63:56] = debug_wb_rf_wdata[63:56] & {8{debug_wb_rf_wen[7]}};
assign debug_wb_rf_wdata_v[55:48] = debug_wb_rf_wdata[55:48] & {8{debug_wb_rf_wen[6]}};
assign debug_wb_rf_wdata_v[47:40] = debug_wb_rf_wdata[47:40] & {8{debug_wb_rf_wen[5]}};
assign debug_wb_rf_wdata_v[39:32] = debug_wb_rf_wdata[39:32] & {8{debug_wb_rf_wen[4]}};
assign debug_wb_rf_wdata_v[31:24] = debug_wb_rf_wdata[31:24] & {8{debug_wb_rf_wen[3]}};
assign debug_wb_rf_wdata_v[23:16] = debug_wb_rf_wdata[23:16] & {8{debug_wb_rf_wen[2]}};
assign debug_wb_rf_wdata_v[15: 8] = debug_wb_rf_wdata[15: 8] & {8{debug_wb_rf_wen[1]}};
assign debug_wb_rf_wdata_v[7 : 0] = debug_wb_rf_wdata[7 : 0] & {8{debug_wb_rf_wen[0]}};

//get reference result in falling edge
reg        trace_cmp_flag;
reg        debug_end;

reg [31:0] ref_wb_pc;
reg [4 :0] ref_wb_rf_wnum;
reg [63:0] ref_wb_rf_wdata_v;
reg [63:0] debug_rf [31:0];
reg [31:0] line;

// open the trace file;
integer trace_ref;
reg [31:0] ref_line;
reg trash;

task unit_test;
input [64*8-1:0] test_name;
input [9:0] test_line;
begin
    clk = 1'b0;
    resetn = 1'b0;
    #2000;
    resetn = 1'b1;
    $display("START TEST: %0s",test_name);
    trash = 1'b1;
    trace_ref = $fopen({"../../../../../../../cpu132_gettrace/ans/",test_name,"-riscv64-nemu.ans"}, "r");
    ref_line = test_line;
    $readmemh({"../../../../../../../cpu132_gettrace/data/",test_name,"-riscv64-nemu.data"},soc_lite.u_axi4_slave.u_ram.mem);//TODO
    
    // #5000
    while(ref_line!==line) begin
        #10
        trash = ~trash;
    end
    // $display("%d,%d",ref_line,line);
    if (ref_line==line) begin
        $display("TEST PASS:%0s",test_name);
        // $finish;
    end
end
endtask



always @(posedge soc_clk)
begin 
    #1;
    if (!resetn) begin
        line <= 32'b0;
    end
    if(|debug_wb_rf_wen && debug_wb_rf_wnum!=5'd0 && debug_rf[debug_wb_rf_wnum]!==debug_wb_rf_wdata_v && `CONFREG_OPEN_TRACE)
    begin
        trace_cmp_flag=1'b0;
        while (!trace_cmp_flag && !($feof(trace_ref)))
        begin
            $fscanf(trace_ref, "%h %h $%d %h", trace_cmp_flag,
                    ref_wb_pc, ref_wb_rf_wnum, ref_wb_rf_wdata_v);
            line <= line + 1'b1;
        end
    end
end

//compare result in rsing edge 
reg debug_wb_err;
always @(posedge soc_clk)
begin
    #2;
    if(!resetn)
    begin
        debug_wb_err <= 1'b0;
        debug_rf[0] <= 0;
        debug_rf[1] <= 0;
        debug_rf[2] <= 0;
        debug_rf[3] <= 0;
        debug_rf[4] <= 0;
        debug_rf[5] <= 0;
        debug_rf[6] <= 0;
        debug_rf[7] <= 0;
        debug_rf[8] <= 0;
        debug_rf[9] <= 0;
        debug_rf[10] <= 0;
        debug_rf[11] <= 0;
        debug_rf[12] <= 0;
        debug_rf[13] <= 0;
        debug_rf[14] <= 0;
        debug_rf[15] <= 0;
        debug_rf[16] <= 0;
        debug_rf[17] <= 0;
        debug_rf[18] <= 0;
        debug_rf[19] <= 0;
        debug_rf[20] <= 0;
        debug_rf[21] <= 0;
        debug_rf[22] <= 0;
        debug_rf[23] <= 0;
        debug_rf[24] <= 0;
        debug_rf[25] <= 0;
        debug_rf[26] <= 0;
        debug_rf[27] <= 0;
        debug_rf[28] <= 0;
        debug_rf[29] <= 0;
        debug_rf[30] <= 0;
        debug_rf[31] <= 0;
    end
    else if(|debug_wb_rf_wen && debug_wb_rf_wnum!=5'd0 && debug_rf[debug_wb_rf_wnum]!==debug_wb_rf_wdata_v && `CONFREG_OPEN_TRACE)
    begin
        if (  (debug_wb_pc!==ref_wb_pc) || (debug_wb_rf_wnum!==ref_wb_rf_wnum)
            ||(debug_wb_rf_wdata_v!==ref_wb_rf_wdata_v) )
        begin
            $display("--------------------------------------------------------------");
            $display("[%t] Error!!!",$time);
            $display("    reference: PC = 0x%8h, wb_rf_wnum = 0x%2h, wb_rf_wdata = 0x%8h",
                      ref_wb_pc, ref_wb_rf_wnum, ref_wb_rf_wdata_v);
            $display("    mycpu    : PC = 0x%8h, wb_rf_wnum = 0x%2h, wb_rf_wdata = 0x%8h",
                      debug_wb_pc, debug_wb_rf_wnum, debug_wb_rf_wdata_v);
            $display("--------------------------------------------------------------");
            debug_wb_err <= 1'b1;
            #40;
            $finish;
        end
        else begin
            debug_rf[debug_wb_rf_wnum] <= debug_wb_rf_wdata_v;
        end
    end
end


initial begin
    unit_test("add",220);
    unit_test("addi",115);
    unit_test("addiw",111);
    unit_test("addw",215);
    unit_test("and",355);
    unit_test("andi",113);
    unit_test("auipc",15);
    unit_test("beq",73);
    unit_test("bge",80);
    unit_test("bgeu",215);
    unit_test("blt",72);
    unit_test("bltu",205);
    unit_test("bne",75);
    unit_test("jal",9);
    unit_test("jalr",46);
    unit_test("lb",126);
    unit_test("lbu",126);
    unit_test("ld",266);
    unit_test("lh",142);
    unit_test("lhu",151);
    unit_test("lui",15);
    unit_test("lw",154);
    unit_test("lwu",180);
    unit_test("or",391);
    unit_test("ori",108);
    unit_test("sb",205);
    unit_test("sd",401);
    unit_test("sh",278);
    // unit_test("simple",281);
    unit_test("sll",281);
    unit_test("slli",134);
    unit_test("slliw",140);
    unit_test("sllw",281);
    unit_test("slt",196);
    unit_test("slti",98);
    unit_test("sltiu",98);
    unit_test("sltu",213);
    unit_test("sra",261);
    unit_test("srai",133);
    unit_test("sraiw",171);
    unit_test("sraw",297);
    unit_test("srl",327);
    unit_test("srli",156);
    unit_test("srliw",152);
    unit_test("srlw",287);
    unit_test("sub",211);
    unit_test("subw",206);
    unit_test("sw",289);
    unit_test("xor",387);
    unit_test("xori",106);


    $display("-------ALL TEST FINISH-------- !!!");
    $finish;
end
endmodule
