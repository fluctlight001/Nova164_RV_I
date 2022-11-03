`define StallBus 6
module ctrl(
    input wire rst_n,
    input wire stallreq_id,
    input wire stallreq_ex,
    input wire stallreq_axi,
    output reg [`StallBus-1:0] stall
);
    always @ (*) begin
        if (!rst_n) begin
            stall = `StallBus'b0;
        end
        else if (stallreq_axi) begin
            stall = `StallBus'b111111;
        end
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
