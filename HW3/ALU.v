module ALU(
    input  [31:0] data1_i,
    input  [31:0] data2_i,
    input  [2:0]  ALUCtrl_i,
    output reg [31:0] data_o,
    output zero_o
);

    // Temporary 33-bit wire for addition/subtraction to detect overflow
    wire [32:0] temp_add;
    wire [32:0] temp_sub;
    
    // Calculate addition and subtraction with extra bit
    assign temp_add = {1'b0, data1_i} + {1'b0, data2_i};
    assign temp_sub = {1'b0, data1_i} - {1'b0, data2_i};

    // Zero flag is high when output is zero
    assign zero_o = (data_o == 32'b0);

    // ALU operations
    always @(*) begin
        case (ALUCtrl_i)
            3'b000: data_o = temp_add[31:0];          // Addition with wrap-around
            3'b001: data_o = temp_sub[31:0];          // Subtraction with wrap-around
            3'b010: data_o = data1_i & data2_i;          // Bitwise AND
            3'b011: data_o = data1_i | data2_i;          // Bitwise OR
            3'b100: data_o = data1_i ^ data2_i;          // Bitwise XOR
            3'b101: data_o = data1_i << data2_i[4:0];    // Left Shift
            3'b110: data_o = $signed(data1_i) >>> data2_i[4:0];  // Arithmetic Right Shift
            3'b111: data_o = data1_i >> data2_i[4:0];    // Logical Right Shift
            default: data_o = 32'b0;
        endcase
    end

endmodule