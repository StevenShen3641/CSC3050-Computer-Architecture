// The ID_EX register, you need to do some implementation here.
module ID_EX (
    input CLOCK,
    /* control unit input */
    input RegWrite_in,
    input MemtoReg_in,
    input MemWrite_in,
    input [5:0] Opcode_in,
    input [5:0] Funct_in,
    input ALUSrc_in,
    input RegDst_in,
    /* register input */
    input [31:0] regA_data_in,
    input [31:0] regB_data_in,
    input [4:0] Rs_in,
    input [4:0] Rt_in,
    input [4:0] Rd_in,
    input [4:0] Sa_in,
    /* others input (3)*/
    input [31:0] se_imme_in,
    input Flush,

    /* control unit output */
    output reg RegWrite_out,
    output reg MemtoReg_out,
    output reg MemWrite_out,
    output reg [5:0] Opcode_out,
    output reg [5:0] Funct_out,
    output reg ALUSrc_out,
    output reg RegDst_out,

    /* register output */
    output reg [31:0] regA_data_out,
    output reg [31:0] regB_data_out,
    output reg [4:0] Rs_out,
    output reg [4:0] Rt_out,
    output reg [4:0] Rd_out,
    output reg [4:0] Sa_out,
    /* others output */
    output reg [31:0] se_imme_out
);
    always@(posedge CLOCK) begin
        /* Write your code here */

    end
endmodule


// The ALU unit, you need to do some implementation here.
module ALU (
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [4:0] SrcC,
    input [5:0] Opcode,
    input [5:0] Funct,
    output [31:0] result,
    output reg zero,
    output reg neg
);
    assign result = result_out(SrcA, SrcB, SrcC, Opcode, Funct);

    function [31:0] result_out;
        input [31:0] SrcA;
        input [31:0] SrcB;
        input [4:0] SrcC;
        input [5:0] Opcode;
        input [5:0] Funct;
    begin
        zero = 0;
        neg = 0;
        result_out = 0;

        // you should implement the functionality of ALU,
        // which can refers to your project3. 
        /* Write your code here */
    end
    endfunction
endmodule