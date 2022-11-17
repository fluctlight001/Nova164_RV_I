`define StallBus 6
module ctrl(
    input wire rst_n,
    input wire stallreq_id,
    input wire stallreq_ex,
    input wire stallreq_axi,
    output reg [`StallBus-1:0] stall
);
    //stall[0] --?
    //stall[1] --?
    //stall[2] --id
    //stall[3]
    //stall[4]
    //stall[5]
    always @ (*) begin
        if (!rst_n) begin
            stall = `StallBus'b0;
        end
        else if (stallreq_axi) begin
            stall = `StallBus'b111111;
        end
        //id段发生暂停，此时id及之前暂停
        else if (stallreq_id) begin
            stall = `StallBus'b000111;
        end
        else if (stallreq_ex) begin
            stall = `StallBus'b001111;
        end
        else begin
            stall = `StallBus'b0;
        end
    end
endmodule
