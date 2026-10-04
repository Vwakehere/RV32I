module register_file_tb;
    reg clk = 0;
    reg we;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;
    integer fails = 0;

    register_file dut (.clk(clk),.we(we),.rs1(rs1),.rs2(rs2),.rd(rd),.wd(wd),.rd1(rd1),.rd2(rd2));         

// clock alternating every 5 time units
    always #5 clk = ~clk;


    task check(input [31:0] expected1, expected2);
    begin
       #1;
       if(rd1!==expected1 || rd2!== expected2) begin
        $display("FAIL: rs1 = %0d rs2 = %0d got rd1 = %h rd2 = %h but expected %h and %h",rs1,rs2,rd1,rd2,expected1,expected2);
        fails = fails + 1;
       end 
       else $display("OK: rs1 = %0d rs2 = %0d got rd1 = %h rd2 = %h, expected %h and %h. ",rs1,rs2,rd1,rd2,expected1,expected2);
    end
    endtask

task write_reg(input [4:0] r, input [31:0] v);
    begin
        we = 1; rd = r; wd = v;
        @(posedge clk); #1;      // write lands on the edge
        we = 0;
    end
endtask

    initial begin
        $dumpfile("build/register_file.vcd");
        $dumpvars(0, register_file_tb);
        we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;

// 1. write is NOT visible before the clock edge
we = 1; rd = 5; wd = 32'hABCDEFFF; rs1 = 5;
check(32'h0, 32'h0);                          // still old value
@(posedge clk); #1; we = 0;
check(32'hABCDEFFF, 32'h0);                   // visible after the edge

// 2. two different registers at once
write_reg(7, 32'h12345678);
rs1 = 5; rs2 = 7;
check(32'hABCDEFFF, 32'h12345678);

// 3. same register on both ports
rs1 = 7; rs2 = 7;
check(32'h12345678, 32'h12345678);

// 4. we = 0 doesn't do anything
we = 0;
rd = 5;
wd = 32'h82320422;
@(posedge clk); #1;
rs1 = 5;
rs2 = 7;
check(32'hABCDEFFF,32'h12345678);

// 5. x0 is hardwared to 0, so writing anything to it is ignored.
       write_reg(0,32'hFFFFFFFF);
       rs1 = 0; rs2 = 0;
       check(0,0);
       
        $display("%0d failures", fails);
        $finish;
    end
endmodule