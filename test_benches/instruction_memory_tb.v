module instruction_memory_tb;

    reg  [31:0] address;
    wire [31:0] instruction;

    integer fails = 0;

    instruction_memory 
    // set mem_file parameter for this instance as program.hex (isme jo hex values hai woh load hongi memory mai, if i change it to some other file name, uske andar ki hex values load hongi instruction memory mai)
    #(.MEM_FILE("test_programs/program.hex")) dut ( .address(address),.instruction(instruction) );

    task check(input [31:0] in_address,
               input [31:0] expected_instruction);
        begin
            address = in_address;
            #1;

            if (instruction !== expected_instruction) begin
                $display("FAIL : address=%h, got instruction=%h, expected instruction=%h",
                         in_address, instruction, expected_instruction);
                fails = fails + 1;
            end
            else begin
                $display("PASS : address=%h, got instruction=%h, expected instruction=%h",
                         in_address, instruction, expected_instruction);
            end
        end
    endtask

    initial begin
        $dumpfile("build/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        check(32'h00000000, 32'h00500093);
        check(32'h00000004, 32'hFFF00093);
        check(32'h00000008, 32'h0020A423);
        check(32'h0000000C, 32'h00000013);
        check(32'h00000010, 32'hFFFFFFFF);
        check(32'h00000014, 32'h12345678);
        check(32'h00000018, 32'h80000000);
        check(32'h0000001C, 32'h7FFFFFFF);
        check(32'h00000020, 32'hABCDEF01);

        $display("%0d failures", fails);
        $finish;
    end

endmodule