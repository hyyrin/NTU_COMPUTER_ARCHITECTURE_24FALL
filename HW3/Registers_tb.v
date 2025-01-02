module Registers_tb;
    reg         clk_i;
    reg  [4:0]  RS1addr_i;
    reg  [4:0]  RS2addr_i;
    reg  [4:0]  RDaddr_i;
    reg  [31:0] RDdata_i;
    reg         RegWrite_i;
    wire [31:0] RS1data_o;
    wire [31:0] RS2data_o;

    // Instantiate the register file
    Registers regs(
        .clk_i(clk_i),
        .RS1addr_i(RS1addr_i),
        .RS2addr_i(RS2addr_i),
        .RDaddr_i(RDaddr_i),
        .RDdata_i(RDdata_i),
        .RegWrite_i(RegWrite_i),
        .RS1data_o(RS1data_o),
        .RS2data_o(RS2data_o)
    );

    // Clock generation
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    // Test procedure
    initial begin
        $dumpfile("Registers.vcd");
        $dumpvars(0, Registers_tb);
        
        // Initialize signals
        RS1addr_i = 0;
        RS2addr_i = 0;
        RDaddr_i = 0;
        RDdata_i = 0;
        RegWrite_i = 0;
        #10;

        // Test 1: Write to register 0 (should remain 0)
        RegWrite_i = 1;
        RDaddr_i = 0;
        RDdata_i = 32'hFFFFFFFF;
        #10;
        
        RS1addr_i = 0;
        RegWrite_i = 0;
        #10;
        if(RS1data_o !== 32'h0) 
            $display("Error: Register 0 was modified");
        else 
            $display("Test 1 passed: Register 0 remains 0");

        // Test 2: Write and read from a regular register
        RegWrite_i = 1;
        RDaddr_i = 5'd1;
        RDdata_i = 32'h12345678;
        #10;
        
        RS1addr_i = 5'd1;
        RegWrite_i = 0;
        #10;
        if(RS1data_o !== 32'h12345678)
            $display("Error: Write/Read to register 1 failed");
        else
            $display("Test 2 passed: Write/Read to register 1 successful");

        // Test 3: Simultaneous read from two different registers
        RegWrite_i = 1;
        RDaddr_i = 5'd2;
        RDdata_i = 32'h87654321;
        #10;
        
        RS1addr_i = 5'd1;
        RS2addr_i = 5'd2;
        RegWrite_i = 0;
        #10;
        if(RS1data_o !== 32'h12345678 || RS2data_o !== 32'h87654321)
            $display("Error: Simultaneous read failed");
        else
            $display("Test 3 passed: Simultaneous read successful");

        // Test 4: Write enable functionality
        RegWrite_i = 0;
        RDaddr_i = 5'd1;
        RDdata_i = 32'hAAAAAAAA;
        #10;
        
        RS1addr_i = 5'd1;
        #10;
        if(RS1data_o !== 32'h12345678)
            $display("Error: Write occurred when RegWrite_i was 0");
        else
            $display("Test 4 passed: Write disabled when RegWrite_i = 0");

        // Test 5: Read during write
        RegWrite_i = 1;
        RDaddr_i = 5'd3;
        RDdata_i = 32'hBBBBBBBB;
        RS1addr_i = 5'd3;
        #1;  // Check value before clock edge
        if(RS1data_o !== 32'h0)
            $display("Error: Register 3 should be 0 before write, but got %h", RS1data_o);
        else
            $display("Test 5.1 passed: Register 3 is 0 before write");
        #9;  // Wait for clock edge and check again
        if(RS1data_o !== 32'hBBBBBBBB)
            $display("Error: Read wrong value after write");
        else
            $display("Test 5.2 passed: Read during write successful");

        $finish;
    end
endmodule