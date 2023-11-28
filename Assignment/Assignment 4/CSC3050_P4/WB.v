// The MEM_WB register, you need to do some implementation here
module MEM_WB (
    input CLOCK,
    /* input from CONTROL_UNIT */
    input RegWrite_in,
    input MemtoReg_in,
    /* others (3) */
    input [31:0] ALUOut_in,
    input [31:0] ReadData_in,
    input [4:0] WriteReg_in,

    /* control unit output (2) */
    output reg RegWrite_out,
    output reg MemtoReg_out,
    /* others (3) */
    output reg [31:0] ALUOut_out,
    output reg [31:0] ReadData_out,
    output reg [4:0] WriteReg_out
);
    always@(posedge CLOCK) begin
        /* input from CONTROL_UNIT */
        RegWrite_in = RegWrite_out;
        MemtoReg_in = MemtoReg_out;
        /* others (3) */
        ALUOut_in = ALUOut_out;
        ReadData_in = ReadData_out;
        WriteReg_in = WriteReg_out;
    end
endmodule
