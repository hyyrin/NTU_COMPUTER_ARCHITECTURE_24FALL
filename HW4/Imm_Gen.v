module Imm_Gen(
    input [31:0] instr_i,
    output reg [63:0] imm_o
);
    always @(*) begin
        case(instr_i[6:0])
            7'b0010011: begin  // for I-type
                imm_o = {{52{instr_i[31]}}, instr_i[31:20]};
            end
            default: imm_o = 64'b0;
        endcase
    end
endmodule