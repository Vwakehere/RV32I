module immediate_generator_tb;
    reg  [31:0] inst;
    wire [31:0] imm;
    integer fails = 0;

    immediate_generator dut (.inst(inst), .imm(imm));

    task check(input [31:0] in_inst, expected_imm);
        begin
            inst = in_inst;
            #1;
            if(imm!==expected_imm) begin
                $display("FAIL : inst was %h, got immediate %h, expected immediate %h",in_inst,imm,expected_imm);
                fails = fails+1;
            end
            else $display("PASS : inst was %h, got immediate %h, expected immediate %h",in_inst,imm,expected_imm);
        end
    endtask

    initial begin
        $dumpfile("build/immediate_generator.vcd");
        $dumpvars(0, immediate_generator_tb);

// I format
// ADDI x1, x2, 2047
check(32'h7FF10093, 32'h000007FF);

// ADDI x1, x2, -2048
check(32'h80010093, 32'hFFFFF800);

// ADDI x1, x2, 0
check(32'h00010093, 32'h00000000);

// ADDI x1, x2, -1
check(32'hFFF10093, 32'hFFFFFFFF);

// ADDI x1, x2, 1
check(32'h00110093, 32'h00000001);


//S type

// SW x1, 2047(x2)
check(32'h7E112FA3, 32'h000007FF);

// SW x1, -2048(x2)
check(32'h80112023, 32'hFFFFF800);

// SW x1, 0(x2)
check(32'h00112023, 32'h00000000);

// SW x1, -1(x2)
check(32'hFE112FA3, 32'hFFFFFFFF);

// SW x1, 1(x2)
check(32'h001120A3, 32'h00000001);


// SB type

// BEQ x1, x2, +4094
check(32'h7E208FE3, 32'h00000FFE);

// BEQ x1, x2, -4096
check(32'h80208063, 32'hFFFFF000);

// BEQ x1, x2, -2
check(32'hFE208FE3, 32'hFFFFFFFE);

// BEQ x1, x2, 0
check(32'h00208063, 32'h00000000);

// BEQ x1, x2, +2
check(32'h00208163, 32'h00000002);


// U type

// LUI x1, 0x7FFFF
check(32'h7FFFF0B7, 32'h7FFFF000);

// LUI x1, 0x80000
check(32'h800000B7, 32'h80000000);

// LUI x1, 0xFFFFF
check(32'hFFFFF0B7, 32'hFFFFF000);

// LUI x1, 0x00000
check(32'h000000B7, 32'h00000000);

// LUI x1, 0xABCDE
check(32'hABCDE0B7, 32'hABCDE000);


//J-TYPE

// JAL x1, +2048
check(32'h001000EF, 32'h00000800);

// JAL x1, -2048
check(32'h801FF0EF, 32'hFFFFF800);

// JAL x1, -2
check(32'hFFFFF0EF, 32'hFFFFFFFE);

// JAL x1, 0
check(32'h000000EF, 32'h00000000);

// JAL x1, +2
check(32'h002000EF, 32'h00000002);

// JAL x1, maximum positive offset (+1048574)
check(32'h7FFFF0EF, 32'h000FFFFE);

// JAL x1, maximum negative offset (-1048576)
check(32'h800000EF, 32'hFFF00000);

// lw x1, 4(x2)       (load opcode, I format)
check(32'h00412083, 32'h00000004);

// jalr x1, 8(x2)     (jalr opcode, I format)
check(32'h008100E7, 32'h00000008);

// auipc x1, 0x12345  (auipc opcode, U format)
check(32'h12345097, 32'h12345000);

// add x1, x2, x3     (R-type, no immediate: default case)
check(32'h003100B3, 32'h00000000);


        $display("%0d failures", fails);
        $finish;
    end
endmodule