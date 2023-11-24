// The EX_MEM register, you need to do some implementation here
module EX_MEM (
    input CLOCK,
    /* control unit input */
    input RegWrite_in,
    input MemtoReg_in,
    input MemWrite_in,
    /* ALU input */
    input ALUZero_in,
    input ALUNeg_in,
    input [31:0] ALUOut_in,
    /* others input */
    input [31:0] WriteData_in,
    input [4:0] WriteReg_in,

    /* control unit output */
    output reg RegWrite_out,
    output reg MemtoReg_out,
    output reg MemWrite_out,
    /* ALU output */
    output reg ALUZero_out,
    output reg ALUNeg_out,
    output reg [31:0] ALUOut_out,
    /* others output */
    output reg [31:0] WriteData_out,
    output reg [4:0] WriteReg_out
);
    always@(posedge CLOCK) begin
        /* Write your code here */

    end
endmodule



// The data memory
module DATA_MEM (
    input CLOCK,
    input MemWrite,
    input fin_sign,
    input [31:0] ALUOut_in,
    input [31:0] WriteData_in,
    output [31:0] ReadData_out
);
    reg [31:0] RAM [0:512-1];
    integer out_file;
    integer i;

    initial begin
        for (i = 0; i <= 512-1; i=i+1) begin
            RAM[i] = 32'b0;
        end
    end

    always@(posedge CLOCK) begin
        if (MemWrite == 1'b1) begin
            RAM[ALUOut_in/4] = WriteData_in;
        end
    end

    always@(fin_sign) begin
        if (fin_sign == 1'b1) begin
            out_file = $fopen("data.bin", "w");
            for (i = 0; i <= 512-1; i = i + 1) begin
                $fwrite(out_file, "%b\n", RAM[i]);
            end
            $finish;
        end 
    end
    
    assign ReadData_out = RAM[ALUOut_in/4];
    
endmodule