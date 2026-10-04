
module register_file (
    input clk, // clock 
    input we, // write enable
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0]rd,
    input [31:0]wd,
    output [31:0]rd1,
    output [31:0]rd2
);

// reads are combinational(no clock) writes are clocked

// register set -> 32 registers each of 32 bits
reg [31:0] regs[0:31];


integer i;
// whatever in initial happens, happens only once. no continuous assignment
initial begin
    for (i = 0; i < 32; i = i + 1)
        regs[i] = 32'd0;
end


// write -> if write enable we is high i.e. 1 then at positive edge of clock set value in register no. rd as wd(write data)
always @(posedge clk) begin
    if(we && rd != 0) regs[rd]<= wd;
end
// we have hardwired x0 to 0 as rd would be 5'd0 which would fail the above condition -> no write possible!

// read -> if rs1 is non zero, give me the data in register no. rs1
assign rd1 = (rs1==0) ? 32'd0 : regs[rs1];
assign rd2 = (rs2==0) ? 32'd0 : regs[rs2];


endmodule