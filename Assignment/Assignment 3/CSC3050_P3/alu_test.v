// flags[2] : zero flag
// flags[1] : negative flag
// flags[0] : overflow flag 

// regA: 00000; regB: 00001

module alu(
    input [31:0] instruction,
    input [31:0] regA,
    input [31:0] regB,
    output reg [31:0] result_out,
    output reg [2:0] flags
);

    wire [5:0] Opcode;
    reg [5:0] Funct;
    reg [4:0] rs, rt, rd, SrcC;
    reg [15:0] immediate;
    reg [31:0] SrcA, SrcB;

    reg [31:0] SrcB;  // sign-extended immediate

    assign Opcode = instruction[31:26];

    // parse instruction
    always @(*) begin
        // R-type
        if (Opcode == 6'b0) begin
            rs = instruction[25:21];
            rt = instruction[20:16];
            rd = instruction[15:11];
            SrcC = instruction[10:6];
            Funct = instruction[5:0];
        end
            // I-type
        else begin
            rs = instruction[25:21];
            rt = instruction[20:16];
            immediate = instruction[15:0];
        end
    end

    // fetch register values
    // we only have 00000 and 00001
    always @(*) begin
        if (rs == 5'b0)
            SrcA = regA;
        else
            SrcA = regB;
        if (rt == 5'b0)
            SrcB = regA;
        else
            SrcB = regB;
    end

    // execute different instructions
    always @(*) begin
        flags = 3'b0;  // default the flag
        result_out = 32'b0;  // default the result registers
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
    end
endmodule

