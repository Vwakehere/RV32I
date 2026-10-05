module data_memory(
    input clk,
    input mem_write,
    input mem_read,
    input [31:0] address, wdata,
    output reg [31:0] rdata
);
// will implement the rest of the features later (lb,sb,sh,lh,etc.)

reg[31:0] mem [0:255];

// writing is clocked

// sw implementation
always @(posedge clk) begin
    if(mem_write) mem[address[9:2]] <= wdata; // write the whole word in memory
end

// initialise data in data_memory
integer i ;
initial begin
    for (i=0;i<256;i=i+1) begin
        mem[i]=32'd0;
    end
end


// lw implementation 
always @(*) begin
    if(mem_read) rdata = mem[address[9:2]];
    else rdata = 32'd0;
end



endmodule