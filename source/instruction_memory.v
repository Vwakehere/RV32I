module instruction_memory 
// Set the parameter named MEM_FILE to this value.
#( parameter  MEM_FILE = "test_programs/program.hex")(
input [31:0] address,
output [31:0] instruction
);
/*
This will contain the instructions
*/
reg[31:0] mem[0:255]; // 256 words each with 4 bytes -> 1 kb
/*
mem[0] -> 32 bits
mem[1] -> 32 bits
....
pc gives address of a byte through pc
*/

initial begin
    // read memory hexadecimal
    $readmemh(MEM_FILE,mem);
    // Read hexadecimal values from the file specified by MEM_FILE and put them sequentially into the memory array mem.
end

// 256 locations -> 8 bits to select a word(instruction). PC is byte addressable first two bits of address give offset(byte within the word)
assign instruction = mem[address[9:2]];




endmodule