module branch_unit (
    input [31:0]rs1_val, rs2_val,
    input [2:0] funct3,
    output reg is_branch_taken
);
/*
This unit, takes in the two src operands and using funct3 it determines whether branch is taken or not.
*/
always @(*) begin
    case(funct3)
    // beq -> branch if equal
    3'b000 : is_branch_taken = (rs1_val == rs2_val) ? 1'b1 : 1'b0;
    // bne -> branch if not equal
    3'b001 : is_branch_taken = (rs1_val != rs2_val) ? 1'b1 : 1'b0;
    // blt -> branch if less than(signed)
    3'b100 :  is_branch_taken = ($signed(rs1_val)<$signed(rs2_val)) ? 1'b1 : 1'b0;
    // bge -> branch if greater or equal(signed)
    3'b101 : is_branch_taken =  ($signed(rs1_val)>=$signed(rs2_val)) ? 1'b1 : 1'b0;
    // bltu -> branch if less than(unsigned)
    3'b110 :  is_branch_taken= (rs1_val<rs2_val) ? 1'b1 : 1'b0;
    // bgeu -> branch if greater or equal(unsigned)
    3'b111 :  is_branch_taken = (rs1_val>=rs2_val) ? 1'b1 : 1'b0;
    default : is_branch_taken = 1'b0;
    endcase
end





endmodule