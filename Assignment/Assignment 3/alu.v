// flags[2] : zero flag
// flags[1] : negative flag
// flags[0] : overflow flag 

// regA: 00000; regB: 00001

module alu(
    input[31:0] instruction, 
    input[31:0] regA, 
    input[31:0] regB, 
    output reg[31:0] result, 
    output reg[2:0] flags
);

    wire[5:0] opcode;
    reg[5:0] funct;
    reg[4:0] rs, rt, rd, shamt;
    reg[15:0] immediate;
    reg[31:0] rs_reg, rt_reg;

    reg[31:0] temp_reg;
    integer i; // sra, srav

    assign opcode = instruction[31:26];

    // parse instruction
    always @(*) begin
        // R-type
        if (opcode == 6'b0 ) begin 
            rs = instruction[25:21];
            rt = instruction[20:16];
            rd = instruction[15:11];
            shamt = instruction[10:6];
            funct = instruction[5:0];
        end
        // I-type. We only consider some R-type and I-type instructions in this simple ALU
        else begin 
            rs = instruction[25:21];
            rt = instruction[20:16];
            immediate = instruction[15:0];
        end
    end

    // fetch register values
    always @(*) begin
        if (rs == 5'b0) begin
            rs_reg = regA;
        end
        else begin
            rs_reg = regB;
        end
        if (rt == 5'b0) begin
            rt_reg = regA;
        end
        else begin
            rt_reg = regB;
        end
    end

    // exicute different instructions
    always @(*) begin
        flags = 3'b0;
        // R-type
        if (opcode == 6'b0) begin
            case (funct)
                // addu is implemented follows as an example, you should implement others by yourself.
                6'h21: // addu
                    result = rs_reg + rt_reg;
            endcase
        end

        // I-type
        else begin
            case (opcode)
                // addiu is implemented follows as an example, you should implement others by yourself.
                6'h09: // addiu
                    result = rs_reg + {{(16){immediate[15]}}, immediate};
            endcase
        end
    end
endmodule
