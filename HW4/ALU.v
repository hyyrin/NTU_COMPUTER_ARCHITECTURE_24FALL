module ALU(
    input [63:0] input1_i,
    input [63:0] input2_i,
    input [3:0] ALUCtrl_i,
    output reg [63:0] result_o
);
    always @(*) begin
        case(ALUCtrl_i)
            4'b0010: result_o = input1_i + input2_i;     
            4'b0110: result_o = input1_i - input2_i;    
            4'b0000: result_o = input1_i ^ input2_i;     
            4'b0001: result_o = input1_i | input2_i;    
            4'b0011: result_o = input1_i & input2_i;    
            4'b0100: result_o = input1_i << (input2_i[5:0]);    // sll for lower 6 bits
            4'b0101: result_o = input1_i >> (input2_i[5:0]);    // srl
            4'b0111: result_o = $signed(input1_i) >>> (input2_i[5:0]);  // sra
            default: result_o = 64'b0;
        endcase
    end
endmodule