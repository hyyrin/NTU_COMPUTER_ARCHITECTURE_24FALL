module ALU_Control(
    input [6:0] funct7_i,
    input [2:0] funct3_i,
    input [2:0] ALUOp_i,
    output reg [3:0] ALUCtrl_o //only need 4 bits
);
//decodes funct7 and funct3
    always @(*) begin
        case(ALUOp_i)
            3'b010: begin  // R-type
                case({funct7_i, funct3_i})
                    10'b0000000_000: ALUCtrl_o = 4'b0010;  //add
                    10'b0100000_000: ALUCtrl_o = 4'b0110;  //sub
                    10'b0000000_100: ALUCtrl_o = 4'b0000;  //xor
                    10'b0000000_110: ALUCtrl_o = 4'b0001;  //or
                    10'b0000000_111: ALUCtrl_o = 4'b0011;  //and
                    10'b0000000_001: ALUCtrl_o = 4'b0100;  //sll
                    10'b0000000_101: ALUCtrl_o = 4'b0101;  //srl
                    10'b0100000_101: ALUCtrl_o = 4'b0111;  //sra
                    default: ALUCtrl_o = 4'b1111;
                endcase
            end
            3'b011: begin  // I-type
                case(funct3_i)
                    3'b000: ALUCtrl_o = 4'b0010;  //addi
                    3'b100: ALUCtrl_o = 4'b0000;  //xori
                    3'b110: ALUCtrl_o = 4'b0001;  //ori
                    3'b111: ALUCtrl_o = 4'b0011;  //andi
                    3'b001: ALUCtrl_o = 4'b0100;  //slli
                    3'b101: ALUCtrl_o = funct7_i[5] ? 4'b0111 : 4'b0101;  // srai is 1, srli is 0
                    default: ALUCtrl_o = 4'b1111;
                endcase
            end
            default: ALUCtrl_o = 4'b1111;
        endcase
    end
endmodule