module program_counter(
input clk, reset,
input [31:0] next_program_counter,
output reg[31:0] program_counter
);

always @(posedge clk)
begin
    // If reset reset the program counter to zero else assign program counter the value in next program counter.
    if(reset) program_counter <= 32'd0;
    else program_counter <= next_program_counter;    
end



endmodule