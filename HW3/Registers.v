module Registers(
    input         clk_i,
    input  [4:0]  RS1addr_i,
    input  [4:0]  RS2addr_i,
    input  [4:0]  RDaddr_i,
    input  [31:0] RDdata_i,
    input         RegWrite_i,
    output [31:0] RS1data_o,
    output [31:0] RS2data_o
);

    // Register file
    reg [31:0] registers [0:31];
    integer i;

    // Initialize all registers to 0
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
   

    // Read data
    assign RS1data_o = (RS1addr_i == 5'b0) ? 32'b0 : registers[RS1addr_i];
    assign RS2data_o = (RS2addr_i == 5'b0) ? 32'b0 : registers[RS2addr_i];

    // Write data
    always @(posedge clk_i) begin
        if (RegWrite_i && RDaddr_i != 5'b0) begin
            registers[RDaddr_i] <= RDdata_i;
        end
    end

endmodule