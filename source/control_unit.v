module control_unit (input [6:0] opcode,
input [2:0] funct3, 
input [6:0] funct7,
output reg[3:0] alu_op,
output reg[1:0] alu_src_a, wb_sel,
output reg alu_src_b,reg_write,mem_read,mem_write,branch,jal,jalr,
output reg [1:0] mem_size,// tells the memory how much data the instruction wants(byte,word,half word),
output reg mem_unsigned // unsigned or signed (if data less than a word(sign extension ke liye))
);

/*
Instruction	alu_op	alu_src_a	alu_src_b	reg_write	mem_read	mem_write	wb_sel	branch	jal	jalr
R-type	0–9	0	0	1	0	0	0	0	0	0
I-type ALU	0–9 except SUB	0	1	1	0	0	0	0	0	0
LOAD	ADD	0	1	1	1	0	1	0	0	0
STORE	ADD	0	1	0	0	1	0	0	0	0
BRANCH	SUB	0	0	0	0	0	0	1	0	0
JAL	ADD	1	1	1	0	0	2	0	1	0
JALR	ADD	0	1	1	0	0	2	0	0	1
LUI	ADD	2	1	1	0	0	0	0	0	0
AUIPC	ADD	1	1	1	0	0	0	0	0	0ds

alu_op:
0 = ADD
1 = SUB
2 = SLL
3 = SLT
4 = SLTU
5 = XOR
6 = SRL
7 = SRA
8 = OR
9 = AND

alu_src_a:
0 = rs1
1 = PC
2 = 0

alu_src_b:
0 = rs2
1 = immediate

wb_sel:
0 = ALU result
1 = memory data
2 = PC + 4
*/

// ALU operation codes(fed to ALU unit)
    localparam ADD  = 4'd0;
    localparam SUB  = 4'd1;
    localparam SLL  = 4'd2;
    localparam SLT  = 4'd3;
    localparam SLTU = 4'd4;
    localparam XOR  = 4'd5;
    localparam SRL  = 4'd6;
    localparam SRA  = 4'd7;
    localparam OR   = 4'd8;
    localparam AND  = 4'd9;

    // Opcodes
    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam JAL    = 7'b1101111;
    localparam JALR   = 7'b1100111;
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;



always @(*) begin
        // default value
        alu_op     = ADD; // default alu op is add
        alu_src_a  = 2'd0;
        alu_src_b  = 1'b0;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        wb_sel     = 2'd0;
        branch     = 1'b0;
        jal        = 1'b0;
        jalr       = 1'b0;
        mem_size=2'b10;
        mem_unsigned=1'b0;

        case(opcode) 

        // R - type instruction 
        R_TYPE : begin
            alu_src_a = 2'd0; // 0 means rs1
            alu_src_b = 1'd0; // 0 means rs2
            reg_write = 1'b1; // R type instns require register write
            wb_sel = 2'd0; // 0 means we store alu result in wb
            // we now choose which alu operation on basis of funct3 and funct7
            case(funct3)
            3'b000 : alu_op = (funct7== 7'b0100000) ? SUB : ADD;
            3'b001 : alu_op = SLL;
            3'b010 : alu_op = SLT;
            3'b011 : alu_op = SLTU;
            3'b100 : alu_op = XOR;
            3'b101 : alu_op = (funct7== 7'b0100000) ? SRA : SRL;
            3'b110: alu_op = OR;
            3'b111 : alu_op = AND;
             default: alu_op = AND;
            endcase
        
         end
         // I (ALU)
         I_TYPE : begin
            alu_src_a = 2'd0; // rs1
            alu_src_b = 1'b1; // immediate
            reg_write = 1'b1; 
            wb_sel = 2'd0; // ALU result to be written back in register
            // Again choose alu operation (like R but no sub)
            case(funct3)
                3'b000 : alu_op = ADD; // addi
                3'b010 : alu_op = SLT; // slti
                3'b011 : alu_op = SLTU;// sltui
                3'b100 : alu_op = XOR; // xori
                 3'b110: alu_op = OR;    // ORI
                    3'b111: alu_op = AND;   // ANDI
                    3'b001: alu_op = SLL;   // SLLI
                    // funct7 for srai and srai is given by most significant 7 bits of imm
                    3'b101: alu_op = (funct7 == 7'b0100000) ? SRA : SRL;   // srli or srai

                    default: alu_op = ADD;
            endcase
         end  

           // load instructions
            LOAD: begin
    alu_op=ADD; alu_src_a=2'd0; alu_src_b=1'b1; reg_write=1'b1;
    mem_read=1'b1; wb_sel=2'd1;

    case(funct3)
        3'b000: begin mem_size=2'b00; mem_unsigned=1'b0; end // lb
        3'b001: begin mem_size=2'b01; mem_unsigned=1'b0; end // lh
        3'b010: begin mem_size=2'b10; mem_unsigned=1'b0; end // lw
        3'b100: begin mem_size=2'b00; mem_unsigned=1'b1; end // lbu
        3'b101: begin mem_size=2'b01; mem_unsigned=1'b1; end // lhu
        default: begin mem_size=2'b10; mem_unsigned=1'b0; end
    endcase
end

            // store instruction
           STORE: begin
    alu_op=ADD; alu_src_a=2'd0; alu_src_b=1'b1; mem_write=1'b1;

    case(funct3)
        3'b000: mem_size=2'b00; // sb
        3'b001: mem_size=2'b01; // sh
        3'b010: mem_size=2'b10; // sw
        default: mem_size=2'b10;
    endcase
end


            // branch
            BRANCH: begin
                alu_op    = SUB;
                alu_src_a = 2'd0;   // rs1
                alu_src_b = 1'b0;   // rs2
                branch    = 1'b1; // branch instruction
            end


            // jal 
            JAL: begin
                alu_op    = ADD;
                alu_src_a = 2'd1;   // PC
                alu_src_b = 1'b1;   // immediate
                reg_write = 1'b1;
                wb_sel    = 2'd2;   // PC + 4 -> writes back PC + 4 into register
                jal       = 1'b1;
            end


            // jalr
            JALR: begin
                alu_op    = ADD;
                alu_src_a = 2'd0;   // rs1
                alu_src_b = 1'b1;   // immediate
                reg_write = 1'b1; 
                wb_sel    = 2'd2;   // PC + 4 -> Writes back PC + 4 into register
                jalr      = 1'b1;
            end


            // lui
            LUI: begin
                alu_op    = ADD;
                alu_src_a = 2'd2;   // zero as there is no source!
                alu_src_b = 1'b1;   // immediate
                reg_write = 1'b1;
                wb_sel    = 2'd0;   // ALU result is written into rd
            end


            // auipc
            AUIPC: begin
                alu_op    = ADD;
                alu_src_a = 2'd1;   // PC
                alu_src_b = 1'b1;   // immediate
                reg_write = 1'b1;
                wb_sel    = 2'd0;   // ALU result
            end

            default: begin
                // Keep default control signals
            end  
        endcase
end


endmodule