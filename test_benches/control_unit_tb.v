module control_unit_tb;
reg [6:0] opcode; reg [2:0] funct3; reg [6:0] funct7;
wire [3:0] alu_op; wire [1:0] alu_src_a,wb_sel;
wire alu_src_b,reg_write,mem_read,mem_write,branch,jal,jalr;
integer fails=0;

control_unit dut(.opcode(opcode),.funct3(funct3),.funct7(funct7),.alu_op(alu_op),.alu_src_a(alu_src_a),.alu_src_b(alu_src_b),.reg_write(reg_write),
.mem_read(mem_read),.mem_write(mem_write),.wb_sel(wb_sel),.branch(branch),.jal(jal),.jalr(jalr));
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
    input expected_jalr
);

begin
    opcode=opcode_in; funct3=funct3_in; funct7=funct7_in; #1;

    if(alu_op!==expected_alu_op ||
       alu_src_a!==expected_alu_src_a ||
       alu_src_b!==expected_alu_src_b ||
       reg_write!==expected_reg_write ||
       mem_read!==expected_mem_read ||
       mem_write!==expected_mem_write ||
       wb_sel!==expected_wb_sel ||
       branch!==expected_branch ||
       jal!==expected_jal ||
       jalr!==expected_jalr) begin

        $display("FAIL: op=%b f3=%b f7=%b",opcode_in,funct3_in,funct7_in);
        fails=fails+1;

    end
    else
        $display("PASS: op=%b f3=%b f7=%b",opcode_in,funct3_in,funct7_in);
end
endtask

initial begin
$dumpfile("build/control_unit.vcd"); $dumpvars(0,control_unit_tb);

// R-type
check(7'b0110011,3'b000,7'b0000000,4'd0,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b000,7'b0100000,4'd1,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b001,0,4'd2,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b010,0,4'd3,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b011,0,4'd4,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b100,0,4'd5,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b101,7'b0000000,4'd6,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b101,7'b0100000,4'd7,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b110,0,4'd8,2'd0,0,1,0,0,2'd0,0,0,0);
check(7'b0110011,3'b111,0,4'd9,2'd0,0,1,0,0,2'd0,0,0,0);

// I-type
check(7'b0010011,3'b000,0,4'd0,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b010,0,4'd3,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b011,0,4'd4,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b100,0,4'd5,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b110,0,4'd8,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b111,0,4'd9,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b001,0,4'd2,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b101,0,4'd6,2'd0,1,1,0,0,2'd0,0,0,0);
check(7'b0010011,3'b101,7'b0100000,4'd7,2'd0,1,1,0,0,2'd0,0,0,0);

// Load, Store, Branch
check(7'b0000011,3'b010,0,4'd0,2'd0,1,1,1,0,2'd1,0,0,0);
check(7'b0100011,3'b010,0,4'd0,2'd0,1,0,0,1,2'd0,0,0,0);
check(7'b1100011,3'b000,0,4'd1,2'd0,0,0,0,0,2'd0,1,0,0);

// JAL, JALR, LUI, AUIPC, invalid
check(7'b1101111,0,0,4'd0,2'd1,1,1,0,0,2'd2,0,1,0);
check(7'b1100111,0,0,4'd0,2'd0,1,1,0,0,2'd2,0,0,1);
check(7'b0110111,0,0,4'd0,2'd2,1,1,0,0,2'd0,0,0,0);
check(7'b0010111,0,0,4'd0,2'd1,1,1,0,0,2'd0,0,0,0);
check(7'b1111111,0,0,4'd0,2'd0,0,0,0,0,2'd0,0,0,0);

$display("%0d failures",fails); $finish;
end
endmodule