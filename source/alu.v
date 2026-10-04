

module alu (input[31:0] a, input [31:0]b,
 input [3:0] op, output reg [31:0]y);

always @(*) begin
    case(op) 
    4'd0 : y = a+b; // add
    4'd1 : y = a-b; // sub
    4'd2 : y = a << b[4:0]; // shift a left logical by b[4:0]
    4'd3 : y = ($signed(a)<$signed(b)) ? 32'd1 : 32'd0; // slt
    4'd4 : y = (a<b) ? 32'd1: 32'd0; // sltu
    4'd5 : y = a^b; // xor
    4'd6 : y = a >> b[4:0]; // srl
    4'd7: y = $signed(a) >>> b[4:0]; // sra - if we treat a as signed, then sign extension dppens?
    4'd8 : y = a | b; // or
    4'd9 : y = a & b; // and
    default : y = 32'd0;
    endcase
end


endmodule