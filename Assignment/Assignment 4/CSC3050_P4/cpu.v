// CLK: input clock signal



module CPU (
    input CLK
);
    /* 0 fetch area wires */

    wire CLOCK = CLK;
    wire [2:0] PC_Src_S;
    wire [31:0] PC_pre;
    wire [31:0] PC_F;
    wire [31:0] PC_add4_F;
    wire [31:0] inst_F;
    wire Stall_F;
    wire fin_sign;
    
    /* 1 decode area wires */
    wire [31:0] inst_D;
    wire [31:0] PC_add4_D;
    wire RegWrite_D;
    wire MemtoReg_D;
    wire MemWrite_D;
    wire Branch_D;
    wire Jump_D;
    wire [5:0] Opcode_D;
    wire [5:0] Funct_D;
    wire ALUSrc_D;
    wire RegDst_D;
    wire [31:0] regA_val_D;
    wire [31:0] regB_val_D;
    wire [4:0] Rs_D = inst_D[25:21];
    wire [4:0] Rt_D = inst_D[20:16];
    wire [4:0] Rd_D = inst_D[15:11];
    wire [4:0] Sa_D = inst_D[10:6];
    wire [31:0] se_imme_D;
    wire [31:0] PC_branch_D;
    wire [31:0] PC_jump_D;
    wire Stall_D;
    wire [1:0] ForwardA_D;
    wire [1:0] ForwardB_D;
    wire Flush_D;

    /* 2 excute area wires */
    wire RegWrite_E;
    wire MemtoReg_E;
    wire MemWrite_E;
    wire [5:0] Opcode_E;
    wire [5:0] Funct_E;
    wire ALUSrc_E;
    wire RegDst_E;
    wire [4:0] Rs_E;
    wire [4:0] Rt_E;
    wire [4:0] Rd_E;
    wire [4:0] Sa_E;
    wire [31:0] regA_val_E;
    wire [31:0] regB_val_E;
    wire [31:0] SrcA_E;
    wire [31:0] SrcB_inter_E;
    wire [31:0] SrcB_E;
    wire [4:0] SrcC_E = Sa_E;
    wire [31:0] WriteData_E = SrcB_inter_E;
    wire [4:0] WriteReg_E;
    wire [31:0] se_imme_E;
    wire [31:0] ALUOut_E;
    wire ALUZero_E;
    wire ALUNeg_E;
    wire [1:0] ForwardA_E;
    wire [1:0] ForwardB_E;
    wire Flush_E;

    /* 3 memory area wires */
    wire RegWrite_M;
    wire MemtoReg_M;
    wire MemWrite_M;
    wire ALUZero_M;
    wire ALUNeg_M;
    wire [31:0] ALUOut_M;
    wire [31:0] WriteData_M;
    wire [4:0] WriteReg_M;
    wire [31:0] ReadData_M;

    /* 4 write back area wires */
    wire RegWrite_W;
    wire MemtoReg_W;
    wire [31:0] ALUOut_W;
    wire [31:0] ReadData_W;
    wire [4:0] WriteReg_W;
    wire [31:0] Result_W;

    wire waiting;


    /* modules */
    PC pc(
        .CLOCK (CLOCK), 
        .PC_in (PC_pre),
        .Stall (Stall_F),
        .PC_out (PC_F)
    );
    INSTR_MEM mem(
        .CLOCK (CLOCK),
        .PC_in (PC_F),
        .fin_sign (fin_sign),
        .inst_out (inst_F)
    );

    PC_ADD4 pc_add4(
        .PC_org (PC_F), 
        .PC_add4 (PC_add4_F)
    );
    
    IF_ID if_id(
        .CLOCK (CLOCK), 
        .inst_in (inst_F), 
        .PC_add4_in (PC_add4_F),
        .Flush (Flush_D),
        .Stall (Stall_D),
        .inst_out (inst_D),
        .PC_add4_out (PC_add4_D)
    );

    /* 1 decode area modules */
    CONTROL_UNIT control_unit(
        .opcode_in (inst_D[31:26]), 
        .funct_in (inst_D[5:0]),
        .RegWrite_out (RegWrite_D), 
        .MemtoReg_out (MemtoReg_D), 
        .MemWrite_out (MemWrite_D),
        .Branch_out (Branch_D), 
        .Jump_out (Jump_D), 
        .Opcode_out (Opcode_D), 
        .Funct_out (Funct_D),
        .ALUSrc_out (ALUSrc_D), 
        .RegDst_out (RegDst_D)
    );
    REG_FILE reg_file(
        .CLOCK (CLOCK), 
        .RegWrite (RegWrite_W),
        .regA_addr (inst_D[25:21]), 
        .regB_addr (inst_D[20:16]),
        .regD_addr (WriteReg_W),
        .regD_data (Result_W),
        .Jump_D (Jump_D),
        .Opcode_D (Opcode_D),
        .PC_pre (PC_pre),
        .regA_data (regA_val_D), 
        .regB_data (regB_val_D)
    );
    SIGN_EXT sign_ext(
        .imme_in (inst_D[15:0]), 
        .se_imme_out (se_imme_D)
    );
    BRANCH_GEN branch_gen(
        .se_imme_in (se_imme_D),
        .PC_add4_in (PC_add4_D),
        .branch_out (PC_branch_D)
    );
    JUMP_GEN jump_gen(
        .addr_in (inst_D[25:0]),
        .PC_add4_in (PC_add4_D),
        .jump_out (PC_jump_D)
    );
    ID_EX id_ex(
        .CLOCK (CLOCK),
        /* control unit input */
        .RegWrite_in (RegWrite_D), 
        .MemtoReg_in (MemtoReg_D),
        .MemWrite_in (MemWrite_D),
        .Opcode_in (Opcode_D),
        .Funct_in (Funct_D),
        .ALUSrc_in (ALUSrc_D), 
        .RegDst_in (RegDst_D), 
        /* register input */
        .regA_data_in (regA_val_D), 
        .regB_data_in (regB_val_D),
        .Rs_in (Rs_D), 
        .Rt_in (Rt_D), 
        .Rd_in (Rd_D), 
        .Sa_in (Sa_D),
        /* others input */
        .se_imme_in (se_imme_D),
        .Flush (Flush_E),
        /* control unit output */
        .RegWrite_out (RegWrite_E),
        .MemtoReg_out (MemtoReg_E), 
        .MemWrite_out (MemWrite_E),
        .Opcode_out (Opcode_E), 
        .Funct_out (Funct_E),
        .ALUSrc_out (ALUSrc_E), 
        .RegDst_out (RegDst_E),
        /* register output */
        .regA_data_out (regA_val_E), 
        .regB_data_out (regB_val_E),
        .Rs_out (Rs_E), 
        .Rt_out (Rt_E), 
        .Rd_out (Rd_E), 
        .Sa_out (Sa_E),
        /* others output */
        .se_imme_out (se_imme_E)
    );
    MUX3_BIT32 mux3_bit32_2(
        .A0 (regA_val_E), 
        .A1 (ALUOut_M), 
        .A2 (Result_W), 
        .S (ForwardA_E), 
        .Y (SrcA_E)
    );
    MUX3_BIT32 mux3_bit32_3(
        .A0 (regB_val_E), 
        .A1 (ALUOut_M), 
        .A2 (Result_W), 
        .S (ForwardB_E), 
        .Y (SrcB_inter_E)
    );
    MUX2_BIT32 mux2_bit32_1(
        .A0 (SrcB_inter_E), 
        .A1 (se_imme_E), 
        .S (ALUSrc_E), 
        .Y (SrcB_E)
    );
    MUX2_BIT5 mux2_bit5_1(
        .A0 (Rt_E),
        .A1 (Rd_E), 
        .S (RegDst_E), 
        .Y (WriteReg_E)
    );
    ALU alu(
        .SrcA (SrcA_E),
        .SrcB (SrcB_E), 
        .SrcC (Sa_E), 
        .Opcode (Opcode_E), 
        .Funct (Funct_E),
        .result (ALUOut_E), 
        .zero (ALUZero_E),
        .neg (ALUNeg_E)
    );
    
    EX_MEM ex_mem(
        .CLOCK (CLOCK),
        /* input */
        .RegWrite_in (RegWrite_E),
        .MemtoReg_in (MemtoReg_E), 
        .MemWrite_in (MemWrite_E), 
        .ALUZero_in (ALUZero_E), 
        .ALUNeg_in (ALUNeg_E), 
        .ALUOut_in (ALUOut_E), 
        .WriteData_in (WriteData_E), 
        .WriteReg_in (WriteReg_E),
        /* output */
        .RegWrite_out (RegWrite_M),
        .MemtoReg_out (MemtoReg_M),
        .MemWrite_out (MemWrite_M),
        .ALUZero_out (ALUZero_M),
        .ALUNeg_out (ALUNeg_M),
        .ALUOut_out (ALUOut_M),
        .WriteData_out (WriteData_M),
        .WriteReg_out (WriteReg_M)
    );

    DATA_MEM data_mem(
        .CLOCK (CLOCK),
        .MemWrite (MemWrite_M),
        .fin_sign (fin_sign),
        .ALUOut_in (ALUOut_M),
        .WriteData_in (WriteData_M),
        .ReadData_out (ReadData_M)
    );
    
    MEM_WB mem_wb(
        .CLOCK(CLOCK),
        /* inputs */
        .RegWrite_in (RegWrite_M),
        .MemtoReg_in (MemtoReg_M),
        .ALUOut_in (ALUOut_M),
        .ReadData_in (ReadData_M), 
        .WriteReg_in (WriteReg_M),
        /* outputs */
        .RegWrite_out (RegWrite_W), 
        .MemtoReg_out (MemtoReg_W), 
        .ALUOut_out (ALUOut_W),
        .ReadData_out (ReadData_W), 
        .WriteReg_out (WriteReg_W)
    );
    MUX2_BIT32 mux2_bit32_2(
        .A0 (ALUOut_W),
        .A1 (ReadData_W), 
        .S (MemtoReg_W), 
        .Y (Result_W)
    );
    PC_SRC pc_src(
        .Branch (Branch_D),
        .Jump(Jump_D),
        .Opcode (Opcode_D),
        .Funct (Funct_D),
        .waiting (waiting),
        .regA_val (regA_val_D),
        .regB_val (regB_val_D),
        .S (PC_Src_S)
    );
    MUX5_BIT32 mux5_bit32_1(
        .A0 (PC_add4_F),
        .A1 (PC_branch_D),
        .A2 (PC_jump_D),
        .A3 (regA_val_D),
        .A4 (PC_add4_D - 4),
        .S (PC_Src_S),
        .Y (PC_pre)
    );

    HAZARD_UNIT hazard_unit(
        .Opcode_D (Opcode_D),
        .Funct_D (Funct_D),
        .PC_Src_S (PC_Src_S),
        .RegWrite_E (RegWrite_E),
        .RegWrite_M (RegWrite_M),
        .RegWrite_W (RegWrite_W),
        .MemtoReg_E (MemtoReg_E),
        .MemtoReg_M (MemtoReg_M),
        .MemtoReg_W (MemtoReg_W),
        .WriteReg_E (WriteReg_E),
        .WriteReg_M (WriteReg_M),
        .WriteReg_W (WriteReg_W),
        .Rs_E (Rs_E),
        .Rt_E (Rt_E),
        .ForwardA_E (ForwardA_E),
        .ForwardB_E (ForwardB_E),
        .Rs_D (Rs_D),
        .Rt_D (Rt_D),
        .Stall_F (Stall_F),
        .Stall_D (Stall_D),
        .Flush_E (Flush_E),
        .Flush_D (Flush_D),
        .waiting (waiting)
    );
endmodule