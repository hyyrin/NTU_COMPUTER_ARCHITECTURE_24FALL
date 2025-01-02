module Control(
    input [6:0] opcode_i,
    output reg [2:0] ALUOp_o,
    output reg ALUSrc_o,
    output reg RegWrite_o
);
    always @(*) begin
        case(opcode_i)
            7'b0110011: begin  // R-type instructions
                ALUOp_o = 3'b010;
                ALUSrc_o = 1'b0;
                RegWrite_o = 1'b1;
            end
            7'b0010011: begin  // I-type instructions
                ALUOp_o = 3'b011;
                ALUSrc_o = 1'b1;
                RegWrite_o = 1'b1;
            end
            default: begin
                ALUOp_o = 3'b000;
                ALUSrc_o = 1'b0;
                RegWrite_o = 1'b0;
            end
        endcase
    end
endmodule