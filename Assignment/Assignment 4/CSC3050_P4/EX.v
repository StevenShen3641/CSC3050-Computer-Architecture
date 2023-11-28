// ID_EX
// The ID_EX register, you need to do some implementation here.
module ID_EX (
    input CLOCK,
    /* input from CONTROL_UNIT */
    input RegWrite_in,
    input MemtoReg_in,
    input MemWrite_in,
    input [5:0] Opcode_in,
    input [5:0] Funct_in,
    input ALUSrc_in,
    input RegDst_in,
    /* input from REG_FILE */
    input [31:0] regA_data_in,
    input [31:0] regB_data_in,
    /* input from inst_D */
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
        regA_data_out = regA_data_in;
        regB_data_out = regB_data_in;
        Rs_out = Rs_in;
        Rt_out = Rt_in;
        Rd_out = Rd_in;
        Sa_out = Sa_in;
        se_imme_out = se_imme_in;
        // flush
        if (Flush == 1'b1) begin
            /* control unit output */
            RegWrite_out = 1'b0;
            MemtoReg_out = 1'b0;
            MemWrite_out = 1'b0;
            Opcode_out = 6'b0;
            Funct_out = 6'b0;
            ALUSrc_out = 1'b0;
            RegDst_out = 1'b0;
        end
        else begin
            /* control unit output */
            RegWrite_out = RegWrite_in;
            MemtoReg_out = MemtoReg_in;
            MemWrite_out = MemWrite_in;
            Opcode_out = Opcode_in;
            Funct_out = Funct_in;
            ALUSrc_out = ALUSrc_in;
            RegDst_out = RegDst_in;
        end

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
            case (Opcode)
                // R-type
                6'h00: begin
                    case (Funct)
                        6'h20:  // add
                            result_out = SrcA+SrcB;
                        6'h21:  // addu
                            result_out = SrcA+SrcB;
                        6'h24:  // and
                            result_out = SrcA & SrcB;
                        6'h27:  // nor
                            result_out = ~(SrcA | SrcB);
                        6'h25:  // or
                            result_out = SrcA | SrcB;
                        6'h00:  // sll
                            result_out = SrcB << SrcC;
                        6'h04:  // sllv
                            result_out = SrcB << SrcA;
                        6'h2A: begin  // slt
                            if (SrcA[31] == 1 && SrcB[31] == 0) begin
                                neg = 1'b1;
                                result_out = 32'b1;
                            end
                            else if (SrcA[31] == 0 && SrcB[31] == 1) begin
                                neg = 1'b0;
                                result_out = 32'b0;
                            end
                            else if ($signed(SrcA-SrcB) < 0) begin
                                neg = 1'b1;
                                result = 32'b1;
                            end
                            else begin
                                neg = 1'b0;
                                result = 32'b0;
                            end
                        end
                        6'h03:  // sra
                            result_out = $signed(SrcB) >>> SrcC;
                        6'h07:  // srav
                            result_out = $signed(SrcB) >>> SrcA;
                        6'h02:  // srl
                            result_out = SrcB >> SrcC;
                        6'h06:  // srlv
                            result_out = SrcB >> SrcA;
                        6'h22: begin  // sub
                            result_out = SrcA-SrcB;
                        end
                        6'h23:  // subu
                            result_out = SrcA-SrcB;
                        6'h26:  // xor
                            result_out = SrcA ^ SrcB;
                    endcase
                end

                // I-type
                6'h08:  // addi
                    result_out = SrcA+SrcB;
                6'h09:  // addiu
                    result_out = SrcA+SrcB;
                6'h0C:  // andi
                    result_out = SrcA & {16'b0, SrcB[15:0]};
                6'h04: begin  // beq
                    result_out = SrcA-SrcB;
                    if (result_out == 32'b0)
                        zero = 1'b1;
                    else
                        zero = 1'b0;
                end
                6'h05: begin  // bne
                    result_out = SrcA-SrcB;
                    if (result_out == 32'b0)
                        zero = 1'b1;
                    else
                        zero = 1'b0;
                end
                6'h23:  // lw
                    result_out = SrcA+SrcB;
                6'h0D:  // ori
                    result_out = SrcA | {16'b0, SrcB[15:0]};
                6'h2B: // sw
                    result_out = SrcA+SrcB;
                6'h0E:  // xori
                    result_out = SrcA ^ {16'b0, SrcB[15:0]};
            endcase
            // check jump cases
        end
    endfunction
endmodule

// MUX2_5: Choose writeReg to be rt or rd.
module MUX2_BIT5 (
    input [4:0] A0,
    input [4:0] A1,
    input S,
    output [4:0] Y
);
    assign Y = Y_out(A0, A1, S);
    function [4:0] Y_out;
        input [4:0] A0;
        input [4:0] A1;
        input S;
        case(S)
            1'b0: Y_out = A0;
            1'b1: Y_out = A1;
        endcase
    endfunction
endmodule

// MUX2_32: Choose SrcB_E to be SrcB intermediate or signed immediate.
// Also used in WB, choose Result_W to be ALU result or read data from memory.
module MUX2_BIT32 (
    input [31:0] A0,
    input [31:0] A1,
    /* 
     0 for SrcB intermediate
     1 for signed immediate
     */
    input S,
    output [31:0] Y
);
    assign Y = Y_out(A0, A1, S);
    function [31:0] Y_out;
        input [31:0] A0,
        input [31:0] A1,
        input S,
        case(s)
            1'b0: Y_out = A0;
            1'b1: Y_out = A1;
        endcase
    endfunction
endmodule

// MUX3: Choose intermediate result to be register value, 
// ALU forwarding result or forwarding write back result.
module MUX3_BIT32 (
    input [31:0] A0,
    input [31:0] A1,
    input [31:0] A2,
    /* 
     00 for register
     01 ALU result
     10 for write back result
     */
    input [1:0] S,
    output [31:0] Y
);
    assign Y = Y_out(A0, A1, A2, S);
    function [31:0] Y_out;
        input [31:0] A0,
        input [31:0] A1,
        input [31:0] A2,
        input [1:0] S,
        case(S)
            2'b00: Y_out = A0;
            2'b01: Y_out = A1;
            2'b10: Y_out = A2;
        endcase
    endfunction
endmodule