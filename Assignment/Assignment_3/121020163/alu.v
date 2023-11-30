// flags[2] : zero flag
// flags[1] : negative flag
// flags[0] : overflow flag 

// regA: 00000; regB: 00001

module alu(
    input [31:0] instruction,
    input [31:0] regA,
    input [31:0] regB,
    output reg [31:0] result,
    output reg [2:0] flags
);

    wire [5:0] opcode;
    reg [5:0] funct;
    reg [4:0] rs, rt, rd, shamt;
    reg [15:0] immediate;
    reg [31:0] rs_reg, rt_reg;

    reg [31:0] temp_reg;  // sign-extended immediate

    assign opcode = instruction[31:26];

    // parse instruction
    always @( * ) begin
        // R-type
        if (opcode == 6'b0) begin
            rs = instruction[25:21];
            rt = instruction[20:16];
            rd = instruction[15:11];
            shamt = instruction[10:6];
            funct = instruction[5:0];
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
    always @( * ) begin
        if (rs == 5'b0)
            rs_reg = regA;
        else
            rs_reg = regB;
        if (rt == 5'b0)
            rt_reg = regA;
        else
            rt_reg = regB;
    end

    // execute different instructions
    always @( * ) begin
        flags = 3'b0;  // default the flag
        result = 32'b0;  // default the result registers
        case (opcode)
            // R-type
            6'h00: begin
                case (funct)
                    6'h20: begin  // add
                        result = rs_reg + rt_reg;
                        if ({result[31], rs_reg[31], rt_reg[31]} == {3'b011} || {result[31], rs_reg[31], rt_reg[31]} ==
                       {3'b100})
                            flags[0] = 1'b1;
                    end
                    6'h21:  // addu
                        result = rs_reg + rt_reg;
                    6'h24:  // and
                        result = rs_reg & rt_reg;
                    6'h27:  // nor
                        result = ~ (rs_reg | rt_reg);
                    6'h25:  // or
                        result = rs_reg | rt_reg;
                    6'h00:  // sll
                        result = rt_reg << shamt;
                    6'h04:  // sllv
                        result = rt_reg << rs_reg;
                    6'h2A: begin  // slt
                        if (rs_reg[31] == 1 && rt_reg[31] == 0) begin
                            flags[1] = 1'b1;
                            result = 32'b1;
                        end
                        else if (rs_reg[31] == 0 && rt_reg[31] == 1) begin
                            flags[1] = 1'b0;
                            result = 32'b0;
                        end
                        else if ($signed(rs_reg - rt_reg) < 0) begin
                            flags[1] = 1'b1;
                            result = 32'b1;
                        end
                        else begin
                            flags[1] = 1'b0;
                            result = 32'b0;
                        end
                    end
                    6'h2B: begin  // sltu
                        if (rs_reg < rt_reg) begin
                            flags[1] = 1'b1;
                            result = 32'b1;
                        end
                        else begin
                            flags[1] = 1'b0;
                            result = 32'b0;
                        end
                    end
                    6'h03:  // sra
                        result = $signed(rt_reg) >>> shamt;
                    6'h07:  // srav
                        result = $signed(rt_reg) >>> rs_reg;
                    6'h02:  // srl
                        result = rt_reg >> shamt;
                    6'h06:  // srlv
                        result = rt_reg >> rs_reg;
                    6'h22: begin  // sub
                        result = rs_reg - rt_reg;
                        if ({result[31], rs_reg[31], rt_reg[31]} == {3'b101} || {result[31], rs_reg[31], rt_reg[31]} ==
                       {3'b010})
                            flags[0] = 1;
                    end
                    6'h23:  // subu
                        result = rs_reg - rt_reg;
                    6'h26:  // xor
                        result = rs_reg ^ rt_reg;
                endcase
            end

            // I-type
            6'h08: begin  // addi
                temp_reg = $signed(immediate);
                result = rs_reg + temp_reg;
                if ({result[31], immediate[15], rs_reg[31]} == {3'b100} || {result[31], immediate[15], rs_reg[31]} == {
                       3'b011})
                    flags[0] = 1;
            end
            6'h09: begin  // addiu
                temp_reg = $signed(immediate);
                result = rs_reg + temp_reg;
            end
            6'h0C:  // andi
                result = rs_reg & {16'b0, immediate};
            6'h04: begin  // beq
                result = rs_reg - rt_reg;
                if (result == 32'b0)
                    flags[2] = 1'b1;
                else
                    flags[2] = 1'b0;
            end
            6'h05: begin  // bne
                result = rs_reg - rt_reg;
                if (result == 32'b0)
                    flags[2] = 1'b1;
                else
                    flags[2] = 1'b0;
            end
            6'h23: begin  // lw
                temp_reg = $signed(immediate);
                result = rs_reg + temp_reg;
            end
            6'h0D:  // ori
                result = rs_reg | {16'b0, immediate};
            6'h0A: begin  // slti
                temp_reg = $signed(immediate);
                if (rs_reg[31] == 1 && temp_reg[31] == 0) begin
                    flags[1] = 1'b1;
                    result = 32'b1;
                end
                else if (rs_reg[31] == 0 && temp_reg[31] == 1) begin
                    flags[1] = 1'b0;
                    result = 32'b0;
                end
                else if ($signed(rs_reg - temp_reg) < 0) begin
                    flags[1] = 1'b1;
                    result = 32'b1;
                end
                else begin
                    flags[1] = 1'b0;
                    result = 32'b0;
                end
            end
            6'h0B: begin  // sltiu
                temp_reg = $signed(immediate);
                if (rs_reg < temp_reg) begin
                    flags[1] = 1'b1;
                    result = 32'b1;
                end
                else begin
                    flags[1] = 1'b0;
                    result = 32'b0;
                end
            end
            6'h2B: begin  // sw
                temp_reg = $signed(immediate);
                result = rs_reg + temp_reg;
            end
            6'h0E:  // xori
                result = rs_reg ^ {16'b0, immediate};
        endcase
    end
endmodule
