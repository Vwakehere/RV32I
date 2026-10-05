module branch_unit_tb;
    reg  [31:0] rs1_val, rs2_val;
    reg  [2:0]  funct3;
    wire        is_branch_taken;
    integer     fails = 0;

    branch_unit dut (.rs1_val(rs1_val), .rs2_val(rs2_val),
                     .funct3(funct3), .is_branch_taken(is_branch_taken));

    task check(input [31:0] in_rs1, in_rs2, input [2:0] in_funct3, input expected_branch);
        begin
            rs1_val = in_rs1;
            rs2_val = in_rs2;
            funct3 = in_funct3;
            #1;
            if(is_branch_taken!==expected_branch) begin
                $display("FAIL : rs1 was %h, rs2 was %h, funct3 was %0b, is_branch_taken was %0b expected %0b",in_rs1,in_rs2,in_funct3,is_branch_taken,expected_branch);
                fails = fails+1;
            end
            else  $display("PASS : rs1 was %h, rs2 was %h, funct3 was %0b, is_branch_taken was %0b expected %0b",in_rs1,in_rs2,in_funct3,is_branch_taken,expected_branch);
    
        end
    endtask

    initial begin
        $dumpfile("build/branch_unit.vcd");
        $dumpvars(0, branch_unit_tb);

        // beq
check(32'd5, 32'd5, 3'b000, 1'b1);
check(32'd5, 32'd3, 3'b000, 1'b0);
check(32'hFFFFFFFF, 32'hFFFFFFFF, 3'b000, 1'b1);
// bne
check(32'd5, 32'd3, 3'b001, 1'b1);
check(32'd5, 32'd5, 3'b001, 1'b0);
// blt (signed)
check(32'd3, 32'd5, 3'b100, 1'b1);
check(32'd5, 32'd3, 3'b100, 1'b0);
check(32'd5, 32'd5, 3'b100, 1'b0);
check(32'hFFFFFFFF, 32'd1, 3'b100, 1'b1);          // -1 < 1
check(32'd1, 32'hFFFFFFFF, 3'b100, 1'b0);
check(32'h80000000, 32'h7FFFFFFF, 3'b100, 1'b1);   // most negative < most positive
// bge (signed)
check(32'd5, 32'd5, 3'b101, 1'b1);
check(32'd3, 32'd5, 3'b101, 1'b0);
check(32'd5, 32'd3, 3'b101, 1'b1);
check(32'hFFFFFFFF, 32'd1, 3'b101, 1'b0);          // -1 >= 1 is false
check(32'd1, 32'hFFFFFFFF, 3'b101, 1'b1);
// bltu (unsigned)
check(32'd3, 32'd5, 3'b110, 1'b1);
check(32'd5, 32'd5, 3'b110, 1'b0);
check(32'hFFFFFFFF, 32'd1, 3'b110, 1'b0);          // 4294967295 < 1 is false
check(32'd1, 32'hFFFFFFFF, 3'b110, 1'b1);
check(32'h80000000, 32'h7FFFFFFF, 3'b110, 1'b0);   // opposite of the blt case
// bgeu (unsigned)
check(32'd5, 32'd5, 3'b111, 1'b1);
check(32'hFFFFFFFF, 32'd1, 3'b111, 1'b1);
check(32'd1, 32'hFFFFFFFF, 3'b111, 1'b0);
check(32'h7FFFFFFF, 32'h80000000, 3'b111, 1'b0);
// invalid funct3 (equal operands, so beq would have said taken)
check(32'd5, 32'd5, 3'b010, 1'b0);
check(32'd5, 32'd5, 3'b011, 1'b0);
        $display("%0d failures", fails);
        $finish;
    end
endmodule