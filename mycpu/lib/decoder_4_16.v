module decoder_4_16(
    input wire [3:0] in,
    output reg [15:0] out
);
    always @ (*) begin
        case(in)
            4'd0:begin out = 16'b1; end
            4'd1:begin out = 16'b10; end
            4'd2:begin out = 16'b100; end
            4'd3:begin out = 16'b1000; end
            4'd4:begin out = 16'b10000; end
            4'd5:begin out = 16'b100000; end
            4'd6:begin out = 16'b1000000; end
            4'd7:begin out = 16'b10000000; end
            4'd8:begin out = 16'b100000000; end
            4'd9:begin out = 16'b1000000000; end
            4'd10:begin out = 16'b10000000000; end
            4'd11:begin out = 16'b100000000000; end
            4'd12:begin out = 16'b1000000000000; end
            4'd13:begin out = 16'b10000000000000; end
            4'd14:begin out = 16'b100000000000000; end
            4'd15:begin out = 16'b1000000000000000; end
            default:begin
                out = 16'b0;
            end
        endcase 
    end
endmodule