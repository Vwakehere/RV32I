`timescale 1ns/1ps

module cpu_tb;

reg clk, reset;
integer fails;

cpu dut(.clk(clk), .reset(reset));

always #5 clk = ~clk;

task check;
    input [31:0] actual;
    input [31:0] expected;
    input [127:0] name;
    begin
        if(actual !== expected) begin
            $display("FAIL: %s | expected=%h actual=%h",
                     name, expected, actual);
            fails = fails + 1;
        end
        else
            $display("PASS: %s | value=%h", name, actual);
    end
endtask

initial begin
    clk = 0;
    reset = 1;
    fails = 0;

    // Reset
    #12;
    reset = 0;

    // Let the program execute
    #200;

    // Add whatever checks are appropriate for the program here.
    // Examples:
    
    // check(dut.reg_file.regs[1], 32'd5,  "x1");
    // check(dut.reg_file.regs[2], 32'd7,  "x2");
    // check(dut.reg_file.regs[3], 32'd12, "x3");
    // check(dut.data_mem.mem[0], 32'd12,   "mem[0]");
// Program II
// check(dut.reg_file.regs[1], 32'd123, "x1");
// check(dut.reg_file.regs[2], 32'd123, "x2");
// check(dut.reg_file.regs[3], 32'd456, "x3");
// check(dut.reg_file.regs[4], 32'd456, "x4");

// check(dut.data_mem.mem[0], 32'd123, "mem[0]");
// check(dut.data_mem.mem[1], 32'd456, "mem[1]");


    if(fails == 0)
        $display("\nALL TESTS PASSED");
    else
        $display("\n%d TESTS FAILED", fails);

    $finish;
end

endmodule