module data_memory(
    input clk,
    input mem_write,
    input mem_read,
    input [1:0] mem_size,
    input mem_unsigned,
    input [31:0] address, wdata,
    output reg [31:0] rdata
);

// will implement byte, halfword and word
// memory operations: lb,lbu,lh,lhu,lw,sb,sh,sw

reg[31:0] mem [0:255];

// writing is clocked

always @(posedge clk) begin
    if(mem_write) begin

        // sb implementation
        if(mem_size == 2'b00) begin
            case(address[1:0])
                2'b00: mem[address[9:2]][7:0]   <= wdata[7:0];
                2'b01: mem[address[9:2]][15:8]  <= wdata[7:0];
                2'b10: mem[address[9:2]][23:16] <= wdata[7:0];
                2'b11: mem[address[9:2]][31:24] <= wdata[7:0];
            endcase
        end

        // sh implementation
        else if(mem_size == 2'b01) begin
            if(address[1] == 1'b0)
                mem[address[9:2]][15:0] <= wdata[15:0];
            else
                mem[address[9:2]][31:16] <= wdata[15:0];
        end

        // sw implementation
        else if(mem_size == 2'b10)
            mem[address[9:2]] <= wdata;

    end
end


// initialise data in data_memory

integer i;
initial begin
    for(i=0;i<256;i=i+1) begin
        mem[i]=32'd0;
    end
end


// reading is combinational

always @(*) begin

    if(mem_read) begin

        // lb and lbu implementation
        if(mem_size == 2'b00) begin

            case(address[1:0])
                2'b00: rdata = mem[address[9:2]][7:0];
                2'b01: rdata = mem[address[9:2]][15:8];
                2'b10: rdata = mem[address[9:2]][23:16];
                2'b11: rdata = mem[address[9:2]][31:24];
            endcase

            // sign extension for lb
            if(!mem_unsigned)
                rdata = {{24{rdata[7]}},rdata[7:0]};

            // zero extension for lbu
            else
                rdata = {24'd0,rdata[7:0]};
        end

        // lh and lhu implementation
        else if(mem_size == 2'b01) begin

            if(address[1] == 1'b0)
                rdata = mem[address[9:2]][15:0];
            else
                rdata = mem[address[9:2]][31:16];

            // sign extension for lh
            if(!mem_unsigned)
                rdata = {{16{rdata[15]}},rdata[15:0]};

            // zero extension for lhu
            else
                rdata = {16'd0,rdata[15:0]};
        end

        // lw implementation
        else if(mem_size == 2'b10)
            rdata = mem[address[9:2]];

        else
            rdata = 32'd0;

    end

    else
        rdata = 32'd0;

end

endmodule