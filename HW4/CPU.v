/*
`include "PC.v"
`include "Instruction_Memory.v"
`include "Control.v"
`include "Imm_Gen.v"
`include "Registers.v"
`include "ALU_Control.v"
`include "ALU.v"
*/
module CPU
(
    input clk_i, 
    input rst_i
);

// TODO: Implement your CPU here


    wire [63:0] pc_current, pc_next;
    wire [31:0] instruction;
    wire [63:0] rs1_data, rs2_data, rd_data;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [63:0] alu_input2, alu_result;
    wire [3:0] alu_ctrl;
    wire [63:0] imm_extended;
    wire reg_write;
    wire [2:0] alu_op;
    wire alu_src;

   
    PC PC(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_i(pc_next),
        .pc_o(pc_current)
    );


    Instruction_Memory Instruction_Memory(
        .addr_i(pc_current),
        .instr_o(instruction)
    );

   
    Control Control(
        .opcode_i(instruction[6:0]),
        .ALUOp_o(alu_op),
        .ALUSrc_o(alu_src),
        .RegWrite_o(reg_write)
    );

    
    Imm_Gen Imm_Gen(
        .instr_i(instruction),
        .imm_o(imm_extended)
    );

    
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr = instruction[11:7];

    Registers Registers(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .RS1addr_i(rs1_addr),
        .RS2addr_i(rs2_addr),
        .RDaddr_i(rd_addr),
        .RDdata_i(rd_data),
        .RegWrite_i(reg_write),
        .RS1data_o(rs1_data),
        .RS2data_o(rs2_data)
    );

    ALU_Control ALU_Control(
        .funct7_i(instruction[31:25]),
        .funct3_i(instruction[14:12]),
        .ALUOp_i(alu_op),
        .ALUCtrl_o(alu_ctrl)
    );

    //alu multiplexier
    assign alu_input2 = alu_src ? imm_extended : rs2_data;

    ALU ALU(
        .input1_i(rs1_data),
        .input2_i(alu_input2),
        .ALUCtrl_i(alu_ctrl),
        .result_o(alu_result)
    );

    // write back
    assign rd_data = alu_result;

    // PC = PC + 4 (no branch jump)
    assign pc_next = pc_current + 64'd4;

endmodule
