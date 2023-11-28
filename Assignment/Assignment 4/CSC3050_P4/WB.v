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
        RegWrite_out = RegWrite_in;
        MemtoReg_out = MemtoReg_in;
        /* others (3) */
        ALUOut_out = ALUOut_in;
        ReadData_out = ReadData_in;
        WriteReg_out = WriteReg_in;
    end
endmodule
