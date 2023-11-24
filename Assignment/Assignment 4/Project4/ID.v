// The IF_ID register, you need to do some implementation here.
module IF_ID (
    input CLOCK,
    input [31:0] inst_in,
    input [31:0] PC_add4_in,
    input Flush,
    input Stall,
    output reg [31:0] inst_out,
    output reg [31:0] PC_add4_out
);  
    always@(posedge CLOCK) begin
        if (Stall != 1'b1 && Flush == 1'b0) begin
            /* Write your code here */    

        end
        if (Flush == 1'b1) begin
            /* Write your code here */ 

        end
    end

endmodule



// The control unit, you need to do some implementation here
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
    /* Write your code here. */ 
    // wire R_addu =
    // wire R_sub =
    // wire R_subu =
    // wire R_and =
    // wire R_nor =
    // wire R_or =
    // wire R_xor =
    // wire R_sll =
    // wire R_sllv =
    // wire R_srl =
    // wire R_srlv =
    // wire R_sra =
    // wire R_srav =
    // wire R_slt =
    // wire R_jr =
    
    // I-type
    // wire I_addi =
    // wire I_addiu =
    // wire I_andi =
    // wire I_ori =
    // wire I_xori =
    // wire I_beq =
    // wire I_bne =
    // wire I_lw =
    // wire I_sw =
    
    // J-type
    // wire J_j =
    // wire J_jal =

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


// Simulating a register which can write and read
module REG_FILE (
    /* input */
    input CLOCK,
    input RegWrite,
    input [4:0] regA_addr,
    input [4:0] regB_addr,
    input [4:0] regD_addr,
    input [31:0] regD_data,
    input Jump_D,
    input [5:0] Opcode_D,
    input [31:0] PC_pre,
    /* output */
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

    always@(posedge CLOCK, regD_data) begin
        if (RegWrite == 1'b1) begin
            simu_register[regD_addr] = regD_data;
        end
    end

    always@(Jump_D, Opcode_D) begin
        if (Jump_D == 1'b1 && Opcode_D == 6'b000011)
        begin
            simu_register[31] <= PC_pre;
        end
    end
endmodule



// Sign extention
module SIGN_EXT (
    input [15:0] imme_in,
    output wire [31:0] se_imme_out
);  
    assign se_imme_out = $signed(imme_in);
endmodule


// Generating jump address
module JUMP_GEN (
    input [25:0] addr_in,
    input [31:0] PC_add4_in,
    output [31:0] jump_out
);
    assign jump_out = {PC_add4_in[31:28], 28'b0} + ({6'b0,addr_in})*4 ;
endmodule

// Generating branch address
module BRANCH_GEN (
    input [31:0] se_imme_in,
    input [31:0] PC_add4_in,
    output [31:0] branch_out
);
    assign branch_out = PC_add4_in + se_imme_in*4;
endmodule