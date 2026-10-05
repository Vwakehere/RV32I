module program_counter_tb;

    reg        clk, reset;
    reg [31:0] next_program_counter;
    wire [31:0] program_counter;

    integer fails = 0;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .next_program_counter(next_program_counter),
        .program_counter(program_counter)
    );

    // Clock generation
    always #5 clk = ~clk;

    task check(input in_reset,
               input [31:0] in_next_program_counter,
               input [31:0] expected_pc);
        begin
            reset = in_reset;
            next_program_counter = in_next_program_counter;
            // always wait for positive edge of clk to check value given by program_counter module.
            @(posedge clk);
            #1;

            if (program_counter !== expected_pc) begin
                $display("FAIL : reset=%b, next_pc=%h, got pc=%h, expected pc=%h",
                         in_reset, in_next_program_counter, program_counter, expected_pc);
                fails = fails + 1;
            end
            else begin
                $display("PASS : reset=%b, next_pc=%h, got pc=%h, expected pc=%h",
                         in_reset, in_next_program_counter, program_counter, expected_pc);
            end
        end
    endtask

    initial begin
        $dumpfile("build/program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        clk = 0;
        reset = 0;
        next_program_counter = 32'd0;

        // Reset should set PC to 0
        check(1'b1, 32'h12345678, 32'h00000000);

        // Normal operation: PC should load next PC
        check(1'b0, 32'h00000004, 32'h00000004);

        // Load another PC
        check(1'b0, 32'h00000008, 32'h00000008);

        // Large value
        check(1'b0, 32'hFFFFFFFF, 32'hFFFFFFFF);

        // Reset must override next_program_counter
        check(1'b1, 32'hABCDEF00, 32'h00000000);

        // Normal operation after reset
        check(1'b0, 32'h00000100, 32'h00000100);

        // Check another arbitrary address
        check(1'b0, 32'h80000000, 32'h80000000);

        $display("%0d failures", fails);
        $finish;
    end

endmodule