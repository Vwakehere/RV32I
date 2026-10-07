module control_unit_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire [3:0] alu_op;
wire [1:0] alu_src_a, wb_sel;
wire alu_src_b, reg_write, mem_read, mem_write;
wire branch, jal, jalr;
wire [1:0] mem_size;
wire mem_unsigned;

integer fails = 0;

control_unit dut(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .alu_op(alu_op),
    .alu_src_a(alu_src_a),
    .alu_src_b(alu_src_b),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .wb_sel(wb_sel),
    .branch(branch),
    .jal(jal),
    .jalr(jalr),
    .mem_size(mem_size),
    .mem_unsigned(mem_unsigned)
);

task check(
    input [6:0] opcode_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input [3:0] expected_alu_op,
    input [1:0] expected_alu_src_a,
    input expected_alu_src_b,
    input expected_reg_write,
    input expected_mem_read,
    input expected_mem_write,
    input [1:0] expected_wb_sel,
    input expected_branch,
    input expected_jal,
    input expected_jalr,
    input [1:0] expected_mem_size,
    input expected_mem_unsigned
);
begin
    opcode = opcode_in;
    funct3 = funct3_in;
    funct7 = funct7_in;
    #1;

    if(alu_op !== expected_alu_op ||
       alu_src_a !== expected_alu_src_a ||
       alu_src_b !== expected_alu_src_b ||
       reg_write !== expected_reg_write ||
       mem_read !== expected_mem_read ||
       mem_write !== expected_mem_write ||
       wb_sel !== expected_wb_sel ||
       branch !== expected_branch ||
       jal !== expected_jal ||
       jalr !== expected_jalr ||
       mem_size !== expected_mem_size ||
       mem_unsigned !== expected_mem_unsigned) begin

        $display("FAIL: op=%b f3=%b f7=%b",
                 opcode_in, funct3_in, funct7_in);
        fails = fails + 1;
    end
    else
        $display("PASS: op=%b f3=%b f7=%b",
                 opcode_in, funct3_in, funct7_in);
end
endtask

initial begin

    // LB
    check(7'b0000011,3'b000,7'b0000000,
          4'd0,2'd0,1'b1,1'b1,1'b1,1'b0,2'd1,
          1'b0,1'b0,1'b0,2'b00,1'b0);

    // LH
    check(7'b0000011,3'b001,7'b0000000,
          4'd0,2'd0,1'b1,1'b1,1'b1,1'b0,2'd1,
          1'b0,1'b0,1'b0,2'b01,1'b0);

    // LW
    check(7'b0000011,3'b010,7'b0000000,
          4'd0,2'd0,1'b1,1'b1,1'b1,1'b0,2'd1,
          1'b0,1'b0,1'b0,2'b10,1'b0);

    // LBU
    check(7'b0000011,3'b100,7'b0000000,
          4'd0,2'd0,1'b1,1'b1,1'b1,1'b0,2'd1,
          1'b0,1'b0,1'b0,2'b00,1'b1);

    // LHU
    check(7'b0000011,3'b101,7'b0000000,
          4'd0,2'd0,1'b1,1'b1,1'b1,1'b0,2'd1,
          1'b0,1'b0,1'b0,2'b01,1'b1);

    // SB
    check(7'b0100011,3'b000,7'b0000000,
          4'd0,2'd0,1'b1,1'b0,1'b0,1'b1,2'd0,
          1'b0,1'b0,1'b0,2'b00,1'b0);

    // SH
    check(7'b0100011,3'b001,7'b0000000,
          4'd0,2'd0,1'b1,1'b0,1'b0,1'b1,2'd0,
          1'b0,1'b0,1'b0,2'b01,1'b0);

    // SW
    check(7'b0100011,3'b010,7'b0000000,
          4'd0,2'd0,1'b1,1'b0,1'b0,1'b1,2'd0,
          1'b0,1'b0,1'b0,2'b10,1'b0);

    $display("%0d failures", fails);
    $finish;
end

endmodule