module alu_tb;

reg [31:0] a,b;
reg [3:0] op;
wire [31:0] y;
integer fails = 0;
alu dut (.a(a),.b(b),.op(op),.y(y));
task check(input [31:0] op1,op2 , input [3:0] operation, input [31:0] expected);
    begin
        a = op1; b = op2; op = operation; #1;
        if (y !== expected) begin
            $display("FAIL: %h and %h as input under operation %h got %h, expected %h", op1, op2, operation,y, expected); 
            fails++;
        end
        else               $display("OK: %h and %h as input under operation %h got %h, expected %h", op1, op2, operation,y, expected);
    end
    endtask

initial begin
    $dumpfile("build/alu.vcd");
    $dumpvars(0,alu_tb);

    // add (0)
check(32'hFFFFFFFF, 32'h1,        4'd0, 32'h0);
check(32'h7FFFFFFF, 32'h1,        4'd0, 32'h80000000);
// sub (1)
check(32'h0,        32'h1,        4'd1, 32'hFFFFFFFF);
check(32'h80000000, 32'h1,        4'd1, 32'h7FFFFFFF);
// sll (2)
check(32'h1,        32'd31,       4'd2, 32'h80000000);
check(32'h1,        32'd32,       4'd2, 32'h1);
check(32'h1,        32'd33,       4'd2, 32'h2);
check(32'h1,        32'hFFFFFFE1, 4'd2, 32'h2);        // only b[4:0] matters
// slt (3)
check(32'hFFFFFFFF, 32'h1,        4'd3, 32'h1);
check(32'h80000000, 32'h7FFFFFFF, 4'd3, 32'h1);
check(32'h5,        32'h5,        4'd3, 32'h0);
// sltu (4)
check(32'hFFFFFFFF, 32'h1,        4'd4, 32'h0);
check(32'h80000000, 32'h7FFFFFFF, 4'd4, 32'h0);
check(32'h1,        32'hFFFFFFFF, 4'd4, 32'h1);
// xor (5)
check(32'hFF,       32'hFF,       4'd5, 32'h0);
// srl (6)
check(32'h80000000, 32'd4,        4'd6, 32'h08000000);
check(32'h80000000, 32'd31,       4'd6, 32'h1);
// sra (7)
check(32'h80000000, 32'd4,        4'd7, 32'hF8000000);
check(32'h80000000, 32'd31,       4'd7, 32'hFFFFFFFF);
check(32'h7FFFFFFF, 32'd4,        4'd7, 32'h07FFFFFF);
// or (8)
check(32'hF0,       32'h0F,       4'd8, 32'hFF);
// and (9)
check(32'hFFFFFFFF, 32'hA5A5A5A5, 4'd9, 32'hA5A5A5A5);
// default
check(32'hFFFFFFFF, 32'hFFFFFFFF, 4'd15, 32'h0);
   $display("%0d failures", fails);
    $finish;
end



endmodule