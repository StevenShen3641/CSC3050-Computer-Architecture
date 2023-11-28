// IF_ID
module IF_ID (
    input CLOCK,
    input [31:0] inst_in,
    input [31:0] PC_add4_in,
    input [31:0] branch_PC,  // check
    input Flush,
    input Stall,
    output reg [31:0] inst_out,
    output reg [31:0] PC_add4_out
);  
    always@(posedge CLOCK) begin
        // if no stalling
        if (Stall != 1'b1 && Flush == 1'b0) begin
            inst_out <= inst_in;
            PC_add4_out <= PC_add4_in;
        end
        // flush
        if (Flush == 1'b1) begin
            inst_out <= 32'b0;
            PC_add4_out <= branch_PC;  // check
        end
    end
endmodule

// CONTROL_UNIT
module CONTROL_UNIT (
    input [5:0] opcode_in,
    input [5:0] funct_in,
    output wire RegWrite_out,
    output wire MemtoReg_out,
    output wire MemWrite_out,
    output wire Branch_out,
    output wire Jump_out,
    output wire [5:0] Opcode_out,
    output wire [5:0] Funct_out,
    output wire ALUSrc_out,
    output wire RegDst_out
);
    
    // R-type
    wire R_add = (opcode_in == 6'b000000 && funct_in == 6'b100000) ? 1 : 0;
    wire R_addu = (opcode_in == 6'b000000 && funct_in == 6'b100001) ? 1 : 0;
    wire R_sub = (opcode_in == 6'b000000 && funct_in == 6'b100010) ? 1 : 0;
    wire R_subu = (opcode_in == 6'b000000 && funct_in == 6'b100011) ? 1 : 0;
    wire R_and = (opcode_in == 6'b000000 && funct_in == 6'b100100) ? 1 : 0;
    wire R_nor = (opcode_in == 6'b000000 && funct_in == 6'b100111) ? 1 : 0;
    wire R_or = (opcode_in == 6'b000000 && funct_in == 6'b100101) ? 1 : 0;
    wire R_xor = (opcode_in == 6'b000000 && funct_in == 6'b100110) ? 1 : 0;
    wire R_sll = (opcode_in == 6'b000000 && funct_in == 6'b000000) ? 1 : 0;
    wire R_sllv = (opcode_in == 6'b000000 && funct_in == 6'b000100) ? 1 : 0;
    wire R_srl = (opcode_in == 6'b000000 && funct_in == 6'b000010) ? 1 : 0;
    wire R_srlv = (opcode_in == 6'b000000 && funct_in == 6'b000110) ? 1 : 0;
    wire R_sra = (opcode_in == 6'b000000 && funct_in == 6'b000011) ? 1 : 0;
    wire R_srav = (opcode_in == 6'b000000 && funct_in == 6'b000111) ? 1 : 0;
    wire R_slt = (opcode_in == 6'b000000 && funct_in == 6'b101010) ? 1 : 0;
    wire R_jr = (opcode_in == 6'b000000 && funct_in == 6'b001000) ? 1 : 0;
    
    // I-type
    wire I_addi = (opcode_in == 6'b001000) ? 1 : 0;
    wire I_addiu = (opcode_in == 6'b001001) ? 1 : 0;
    wire I_andi = (opcode_in == 6'b001100) ? 1 : 0;
    wire I_ori = (opcode_in == 6'b001101) ? 1 : 0;
    wire I_xori = (opcode_in == 6'b001110) ? 1 : 0;
    wire I_beq = (opcode_in == 6'b000100) ? 1 : 0;
    wire I_bne = (opcode_in == 6'b000101) ? 1 : 0;
    wire I_lw = (opcode_in == 6'b100011) ? 1 : 0;
    wire I_sw = (opcode_in == 6'b101011) ? 1 : 0;
    
    // J-type
    wire J_j = (opcode_in == 6'b000010) ? 1 : 0;
    wire J_jal = (opcode_in == 6'b000011) ? 1 : 0;

    assign RegWrite_out = (
        R_add | R_addu | I_addi | I_addiu |
        R_sub | R_subu | R_and | I_andi |
        R_nor | R_or | I_ori | R_xor |
        I_xori | R_sll | R_sllv | R_srl |
        R_srlv | R_sra | R_srav | R_slt |
        I_lw
        ) ? 1 : 0;
    assign MemtoReg_out = ( I_lw ) ? 1 : 0;
    assign MemWrite_out = ( I_sw ) ? 1 : 0;
    assign Branch_out = (
        I_beq | I_bne
        ) ? 1 : 0;
    assign Jump_out = (
        J_j | R_jr |J_jal
        ) ? 1 : 0;
    assign Opcode_out = opcode_in;
    assign Funct_out = funct_in;
    assign ALUSrc_out = (
        I_addi | I_addiu | I_andi | I_ori | 
        I_xori | I_lw | I_sw
        ) ? 1 : 0;
    assign RegDst_out = ~ (
        I_addi | I_addiu | I_andi | I_ori |
        I_xori | I_lw | I_sw
        ) ? 1 : 0;
endmodule


// REG_FILE
module REG_FILE (
    input CLOCK,
    input RegWrite,
    input [4:0] regA_addr,
    input [4:0] regB_addr,
    input [4:0] regD_addr,
    input [31:0] regD_data,
    input Jump_D,
    input [5:0] Opcode_D,
    input [31:0] PC_F,
    output wire [31:0] regA_data,
    output wire [31:0] regB_data
);
    reg [31:0] simu_register [0:31];
    wire [31:0] data_a0 = simu_register[4];
    wire [31:0] data_a1 = simu_register[4];

    initial begin
        simu_register[0] = 32'b0; // zero
        simu_register[28] = 32'h1fffffff; // gp
    end

    assign regA_data = simu_register[regA_addr];
    assign regB_data = simu_register[regB_addr];

    // write
    always@(posedge CLOCK, regD_data) begin
        if (RegWrite == 1'b1) begin
            simu_register[regD_addr] = regD_data;
        end
    end

    // jal
    always@(Jump_D, Opcode_D) begin
        if (Jump_D == 1'b1 && Opcode_D == 6'b000011)
        begin
            simu_register[31] <= PC_F;
        end
    end
endmodule

// SIGN_EXT
module SIGN_EXT (
    input [15:0] imme_in,
    output wire [31:0] se_imme_out
);  
    assign se_imme_out = $signed(imme_in);
endmodule

// BRANCH_GEN
module BRANCH_GEN (
    input [31:0] se_imme_in,
    input [31:0] PC_add4_in,
    output [31:0] branch_out
);
    assign branch_out = PC_add4_in + se_imme_in*4;
endmodule

// JUMP_GEN
module JUMP_GEN (
    input [25:0] addr_in,
    input [31:0] PC_add4_in,
    output [31:0] jump_out
);
    assign jump_out = {PC_add4_in[31:28], 28'b0} + ({6'b0,addr_in})*4 ;
endmodule