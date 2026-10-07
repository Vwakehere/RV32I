module data_memory_tb;

    reg        clk;
    reg        mem_write;
    reg        mem_read;
    reg [1:0]  mem_size;
    reg        mem_unsigned;
    reg [31:0] address;
    reg [31:0] wdata;

    wire [31:0] rdata;

    integer fails = 0;

    data_memory dut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),
        .address(address),
        .wdata(wdata),
        .rdata(rdata)
    );

    // 10 time-unit clock period
    always #5 clk = ~clk;


    task check(
        input in_mem_read,
        input [1:0] in_mem_size,
        input in_mem_unsigned,
        input [31:0] in_address,
        input [31:0] expected_data
    );
        begin
            mem_read = in_mem_read;
            mem_size = in_mem_size;
            mem_unsigned = in_mem_unsigned;
            address = in_address;
            #1;

            if (rdata !== expected_data) begin
                $display("FAIL : mem_read=%b, size=%b, unsigned=%b, address=%h, got=%h, expected=%h",
                         in_mem_read, in_mem_size, in_mem_unsigned,
                         in_address, rdata, expected_data);
                fails = fails + 1;
            end
            else begin
                $display("PASS : mem_read=%b, size=%b, unsigned=%b, address=%h, got=%h",
                         in_mem_read, in_mem_size, in_mem_unsigned,
                         in_address, rdata);
            end
        end
    endtask


    initial begin
        $dumpfile("build/data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        clk = 0;
        mem_write = 0;
        mem_read = 0;
        mem_size = 2'b10;
        mem_unsigned = 0;
        address = 0;
        wdata = 0;


        // Initially memory should contain zeroes
        check(1'b1, 2'b10, 1'b0, 32'h00000000, 32'h00000000);
        check(1'b1, 2'b10, 1'b0, 32'h00000004, 32'h00000000);
        check(1'b1, 2'b10, 1'b0, 32'h00000008, 32'h00000000);

        // Read disabled -> rdata should be zero
        check(1'b0, 2'b10, 1'b0, 32'h00000000, 32'h00000000);


        // Write 0x12345678 to address 0
        address = 32'h00000000;
        wdata = 32'h12345678;
        mem_size = 2'b10;
        mem_write = 1;

        // Write occurs at posedge
        @(posedge clk);
        #1;

        mem_write = 0;

        // Read back using LW
        check(1'b1, 2'b10, 1'b0, 32'h00000000, 32'h12345678);


        // Write a different value to another address
        address = 32'h00000004;
        wdata = 32'hABCDEF01;
        mem_size = 2'b10;
        mem_write = 1;

        @(posedge clk);
        #1;

        mem_write = 0;

        // Check second address
        check(1'b1, 2'b10, 1'b0, 32'h00000004, 32'hABCDEF01);

        // Check first address is unchanged
        check(1'b1, 2'b10, 1'b0, 32'h00000000, 32'h12345678);


        // mem_write = 0 should leave memory unchanged
        address = 32'h00000000;
        wdata = 32'hFFFFFFFF;
        mem_write = 0;

        @(posedge clk);
        #1;

        check(1'b1, 2'b10, 1'b0, 32'h00000000, 32'h12345678);


        // Write to address 0x10
        address = 32'h00000010;
        wdata = 32'hDEADBEEF;
        mem_size = 2'b10;
        mem_write = 1;

        @(posedge clk);
        #1;

        mem_write = 0;

        check(1'b1, 2'b10, 1'b0, 32'h00000010, 32'hDEADBEEF);


        // ---------------- SB ----------------

        // Write AB to byte address 1
        address = 32'h00000001;
        wdata = 32'h000000AB;
        mem_size = 2'b00;
        mem_write = 1;

        @(posedge clk);
        #1;

        mem_write = 0;

        // Whole word should now be 0x1234AB78
        check(1'b1, 2'b10, 1'b0, 32'h00000000, 32'h1234AB78);


        // ---------------- LB ----------------

        // Read byte AB as signed byte
        check(1'b1, 2'b00, 1'b0, 32'h00000001, 32'hFFFFFFAB);


        // ---------------- LBU ----------------

        // Read byte AB as unsigned byte
        check(1'b1, 2'b00, 1'b1, 32'h00000001, 32'h000000AB);


        // ---------------- SH ----------------

        // Write CDEF to bytes 2 and 3
        address = 32'h00000002;
        wdata = 32'h0000CDEF;
        mem_size = 2'b01;
        mem_write = 1;

        @(posedge clk);
        #1;

        mem_write = 0;

        // Whole word should now be CDEFAB78
        check(1'b1, 2'b10, 1'b0, 32'h00000000, 32'hCDEFAB78);


        // ---------------- LH ----------------

        // Read CDEF as signed halfword
        check(1'b1, 2'b01, 1'b0, 32'h00000002, 32'hFFFFCDEF);


        // ---------------- LHU ----------------

        // Read CDEF as unsigned halfword
        check(1'b1, 2'b01, 1'b1, 32'h00000002, 32'h0000CDEF);


        $display("%0d failures", fails);
        $finish;
    end

endmodule