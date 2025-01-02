module ALU_tb;
    reg  [31:0] data1_i;
    reg  [31:0] data2_i;
    reg  [2:0]  ALUCtrl_i;
    wire [31:0] data_o;
    wire zero_o;

    // Instantiate the ALU
    ALU alu(
        .data1_i(data1_i),
        .data2_i(data2_i),
        .ALUCtrl_i(ALUCtrl_i),
        .data_o(data_o),
        .zero_o(zero_o)
    );

    // For printing test results
    reg [255:0] op_name;
    always @(*) begin
        case(ALUCtrl_i)
            3'b000: op_name = "ADD";
            3'b001: op_name = "SUB";
            3'b010: op_name = "AND";
            3'b011: op_name = "OR";
            3'b100: op_name = "XOR";
            3'b101: op_name = "SLL";
            3'b110: op_name = "SRA";
            3'b111: op_name = "SRL";
            default: op_name = "UNKNOWN";
        endcase
    end

    // Test vectors
    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, ALU_tb);
        
        // Test 1: Basic arithmetic operations
        data1_i = 32'h00000005; data2_i = 32'h00000003;

        //data1_i = 32'hFFFFFFFA;
        //data2_i = 32'h0000000A;
        // Addition
        ALUCtrl_i = 3'b000;
        #10;
        if(data_o !== 32'h00000008) $display("Error: ADD failed");

        else $display("Test ADD passed: %h + %h = %h", data1_i, data2_i, data_o);
        
        // Subtraction
        ALUCtrl_i = 3'b001;
        #10;
        if(data_o !== 32'h00000002) $display("Error: SUB failed");
        else $display("Test SUB passed: %h - %h = %h", data1_i, data2_i, data_o);

        // Test 2: Logical operations
        data1_i = 32'hF0F0F0F0; data2_i = 32'h0F0F0F0F;
        
        // AND
        ALUCtrl_i = 3'b010;
        #10;
        if(data_o !== 32'h00000000) $display("Error: AND failed");
        else $display("Test AND passed: %h & %h = %h", data1_i, data2_i, data_o);
        
        // OR
        ALUCtrl_i = 3'b011;
        #10;
        if(data_o !== 32'hFFFFFFFF) $display("Error: OR failed");
        else $display("Test OR passed: %h | %h = %h", data1_i, data2_i, data_o);
        
        // XOR
        ALUCtrl_i = 3'b100;
        #10;
        if(data_o !== 32'hFFFFFFFF) $display("Error: XOR failed");
        else $display("Test XOR passed: %h ^ %h = %h", data1_i, data2_i, data_o);

        // Test 3: Shift operations
        data1_i = 32'h0000FFFF; data2_i = 32'h00000004;
        
        // Logical left shift
        ALUCtrl_i = 3'b101;
        #10;
        if(data_o !== 32'h000FFFF0) $display("Error: SLL failed");
        else $display("Test SLL passed: %h << %h = %h", data1_i, data2_i[4:0], data_o);
        
        // Arithmetic right shift
        data1_i = 32'h80000000;
        ALUCtrl_i = 3'b110;
        #10;
        if(data_o !== 32'hF8000000) $display("Error: SRA failed");
        else $display("Test SRA passed: %h >>> %h = %h", data1_i, data2_i[4:0], data_o);
        
        // Logical right shift
        ALUCtrl_i = 3'b111;
        #10;
        if(data_o !== 32'h08000000) $display("Error: SRL failed");
        else $display("Test SRL passed: %h >> %h = %h", data1_i, data2_i[4:0], data_o);

        // Test 4: Overflow test for addition
        data1_i = 32'hFFFFFFFF; data2_i = 32'h00000001;
        ALUCtrl_i = 3'b000;
        #10;
        if(data_o !== 32'h00000000) $display("Error: ADD overflow failed");
        else $display("Test ADD overflow passed: %h + %h = %h", data1_i, data2_i, data_o);

        // Test 5: Underflow test for subtraction
        data1_i = 32'h00000000; data2_i = 32'h00000001;
        ALUCtrl_i = 3'b001;
        #10;
        if(data_o !== 32'hFFFFFFFF) $display("Error: SUB underflow failed");
        else $display("Test SUB underflow passed: %h - %h = %h", data1_i, data2_i, data_o);

        // Test 6: Zero flag test
        data1_i = 32'h00000000; data2_i = 32'h00000000;
        ALUCtrl_i = 3'b000;
        #10;
        if(!zero_o) $display("Error: Zero flag failed");
        else $display("Test zero flag passed");

        $finish;
    end
endmodule