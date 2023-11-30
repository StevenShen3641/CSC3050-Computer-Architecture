module ControlUnit(
	input wire [5:0] op,
	input wire [4:0] addr_rs,
	input wire [4:0] addr_rt,
	input wire [5:0] funct,
	input wire rs_rt_equal,
	input wire [4:0] write_reg_e,
	input wire reg_write_e,
	input wire is_load_e,
	input wire [4:0] write_reg_m,
	input wire reg_write_m,
	input wire is_load_m,
	output reg reg_write,
	output reg mem_to_reg,
	output reg mem_write,
	output reg mem_used,
	output reg [1:0] pc_src,
	output reg [3:0] ALU_control,
	output reg [1:0] ALU_src_A,
	output reg [1:0] ALU_src_B,
	output reg [1:0] reg_dst,
	output reg ext_sign,
	output reg is_load,
	output reg [1:0] fwd_a,
	output reg [1:0] fwd_b,
	output reg fwd_m,
	output reg en_f,
	output reg en_d,
	output reg rst_d,
	output reg rst_e,
	output reg is_display 
   );
	

// PC sources
localparam
	PC_PLUS4   = 0,
	PC_JUMP    = 1,
	PC_JR      = 2,
	PC_BRANCH  = 3;

// EXE A sources
localparam
	EXE_A_RS     = 0,
	EXE_A_SA     = 1,
	EXE_A_LINK   = 2;

// EXE B sources
localparam
	EXE_B_RT     = 0,
	EXE_B_IMM    = 1,
	EXE_B_LINK   = 2,
	EXE_B_BRANCH = 3;

// EXE ALU operations
localparam
	EXE_ALU_ADD    = 0,
	EXE_ALU_ADDU	= 1,
	EXE_ALU_SUB    = 2,
	EXE_ALU_SUBU 	= 3,
	EXE_ALU_AND    = 4,
	EXE_ALU_NOR		= 5,
	EXE_ALU_OR		= 6,
	EXE_ALU_XOR		= 7,
	EXE_ALU_SLL		= 8,
	EXE_ALU_SLLV	= 9,
	EXE_ALU_SRL		= 10,
	EXE_ALU_SRLV	= 11,
	EXE_ALU_SRA		= 12,
	EXE_ALU_SRAV	= 13,
	EXE_ALU_SLT		= 14;


// WB address sources
localparam
	WB_ADDR_RD    = 0,
	WB_ADDR_RT    = 1,
	WB_ADDR_LINK  = 2;

// WB data sources
localparam
	WB_DATA_ALU   = 0,
	WB_DATA_MEM   = 1;

// instructions
localparam  // bit 31:26 for instruction type
	INST_R          = 6'b000000, 
	R_FUNC_SLL      = 6'b000000,
	R_FUNC_SRL      = 6'b000010,
	R_FUNC_SRA      = 6'b000011,
	R_FUNC_SLLV     = 6'b000100,
	R_FUNC_SRLV     = 6'b000110, 
	R_FUNC_SRAV     = 6'b000111,
	R_FUNC_JR       = 6'b001000,
	R_FUNC_ADD      = 6'b100000,
	R_FUNC_ADDU     = 6'b100001,
	R_FUNC_SUB      = 6'b100010,
	R_FUNC_SUBU     = 6'b100011,
	R_FUNC_AND      = 6'b100100,
	R_FUNC_OR       = 6'b100101,
	R_FUNC_XOR      = 6'b100110,
	R_FUNC_NOR      = 6'b100111,
	R_FUNC_SLT      = 6'b101010,
	R_FUNC_SLTU     = 6'b101011,
	INST_J          = 6'b000010,
	INST_JAL        = 6'b000011,
	INST_BEQ        = 6'b000100,
	INST_BNE        = 6'b000101,
	INST_ADDI       = 6'b001000,
	INST_ADDIU      = 6'b001001,
	INST_SLTI       = 6'b001010,
	INST_SLTIU      = 6'b001011,
	INST_ANDI       = 6'b001100,
	INST_ORI        = 6'b001101,
	INST_XORI       = 6'b001110,
	INST_LUI        = 6'b001111,
	INST_LW         = 6'b100011,
	INST_SW         = 6'b101011,
	INST_STOP       = 6'b111111;

// general registers
localparam
	GPR_ZERO = 0,
	GPR_AT = 1,
	GPR_V0 = 2,
	GPR_V1 = 3,
	GPR_A0 = 4,
	GPR_A1 = 5,
	GPR_A2 = 6,
	GPR_A3 = 7,
	GPR_T0 = 8,
	GPR_T1 = 9,
	GPR_T2 = 10,
	GPR_T3 = 11,
	GPR_T4 = 12,
	GPR_T5 = 13,
	GPR_T6 = 14,
	GPR_T7 = 15,
	GPR_S0 = 16,
	GPR_S1 = 17,
	GPR_S2 = 18,
	GPR_S3 = 19,
	GPR_S4 = 20,
	GPR_S5 = 21,
	GPR_S6 = 22,
	GPR_S7 = 23,
	GPR_T8 = 24,
	GPR_T9 = 25,
	GPR_K0 = 26,
	GPR_K1 = 27,
	GPR_GP = 28,
	GPR_SP = 29,
	GPR_FP = 30,
	GPR_RA = 31;
	
	reg rs_used, rt_used;
	reg is_link;
	reg is_store; 
	
	always @(*) begin
		// initialize basic 
		reg_write = 0;
		mem_to_reg = 0;
		mem_write = 0;
		mem_used = 0;
		pc_src = PC_PLUS4;
		ALU_control = EXE_ALU_ADD;
		ALU_src_A = EXE_A_RS;
		ALU_src_B = EXE_B_RT;
		reg_dst = WB_ADDR_RD;
		ext_sign = 0;
		is_load = 0;
		rs_used = 0;
		rt_used = 0;
		is_store = 0;
		is_link = 0;
		is_display = 0;
		// decode
		case (op)
			// R-type instruction
			INST_R: begin
				case (funct)
					R_FUNC_ADD: begin
						ALU_control = EXE_ALU_ADD;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_ADDU: begin
						ALU_control = EXE_ALU_ADDU;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SUB: begin
						ALU_control = EXE_ALU_SUB;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SUBU: begin
						ALU_control = EXE_ALU_SUBU;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end				
					R_FUNC_AND: begin
						ALU_control = EXE_ALU_AND;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_NOR: begin
						ALU_control = EXE_ALU_NOR;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_OR: begin
						ALU_control = EXE_ALU_OR;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_XOR: begin
						ALU_control = EXE_ALU_XOR;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SLL: begin
						ALU_control = EXE_ALU_SLL;
						ALU_src_A = EXE_A_SA;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SLLV: begin
						ALU_control = EXE_ALU_SLLV;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SRL: begin
						ALU_control = EXE_ALU_SRL;
						ALU_src_A = EXE_A_SA;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SRLV: begin
						ALU_control = EXE_ALU_SRLV;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SRA: begin
						ALU_control = EXE_ALU_SRA;
						ALU_src_A = EXE_A_SA;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SRAV: begin
						ALU_control = EXE_ALU_SRAV;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end	
					R_FUNC_SLT: begin
						ALU_control = EXE_ALU_SLT;
						ALU_src_A = EXE_A_RS;
						ALU_src_B = EXE_B_RT;
						mem_to_reg = 0;
						reg_dst = WB_ADDR_RD;
						reg_write = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_JR: begin
						pc_src = PC_JR;
						rs_used = 1;
						is_link = 1;
					end
				endcase
			end
			// I-type instruction
			INST_ADDI: begin
				ALU_control = EXE_ALU_ADD;
				ALU_src_A = EXE_A_RS;
				ALU_src_B = EXE_B_IMM;
				mem_to_reg = 0;
				reg_dst = WB_ADDR_RT;
				reg_write = 1;
				rs_used = 1;
				ext_sign = 1;
			end
			INST_ADDIU: begin
				ALU_control = EXE_ALU_ADDU;
				ALU_src_A = EXE_A_RS;
				ALU_src_B = EXE_B_IMM;
				mem_to_reg = 0;
				reg_dst = WB_ADDR_RT;
				reg_write = 1;
				rs_used = 1;
				ext_sign = 0;
			end
			INST_ANDI: begin
				ALU_control = EXE_ALU_AND;
				ALU_src_A = EXE_A_RS;
				ALU_src_B = EXE_B_IMM;
				mem_to_reg = 0;
				reg_dst = WB_ADDR_RT;
				reg_write = 1;
				rs_used = 1;
				ext_sign = 0;
			end
			INST_ORI: begin
				ALU_control = EXE_ALU_OR;
				ALU_src_A = EXE_A_RS;
				ALU_src_B = EXE_B_IMM;
				mem_to_reg = 0;
				reg_dst = WB_ADDR_RT;
				reg_write = 1;
				rs_used = 1;
				ext_sign = 0;
			end
			INST_XORI: begin
				ALU_control = EXE_ALU_XOR;
				ALU_src_A = EXE_A_RS;
				ALU_src_B = EXE_B_IMM;
				mem_to_reg = 0;
				reg_dst = WB_ADDR_RT;
				reg_write = 1;
				rs_used = 1;
				ext_sign = 0;
			end
			INST_LW: begin
				ALU_control = EXE_ALU_ADD;
				ALU_src_B = EXE_B_IMM;
				mem_to_reg = 1;
				mem_used = 1;
				reg_dst = WB_ADDR_RT;
				reg_write = 1;
				ext_sign = 1;
				is_load = 1;
				rs_used = 1;		
			end
			INST_SW: begin
				ALU_control = EXE_ALU_ADD;
				ALU_src_B = EXE_B_IMM;
				mem_write = 1;
				mem_used = 1;
				ext_sign = 1;
				is_store = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_BEQ: begin
				if (rs_rt_equal) begin
					pc_src = PC_BRANCH;
					is_link = 1;
				end
				ext_sign = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_BNE: begin
				if (~rs_rt_equal) begin
					pc_src = PC_BRANCH;
					is_link = 1;
				end
				ext_sign = 1;
				rs_used = 1;
				rt_used = 1;
			end
			// J-type instruction
			INST_J: begin
				pc_src = PC_JUMP;
				is_link = 1;
			end
			INST_JAL: begin
				pc_src = PC_JUMP;
				ALU_control = EXE_ALU_ADD;
				ALU_src_A = EXE_A_LINK;
				ALU_src_B = EXE_B_LINK;
				mem_to_reg = 0;
				reg_dst = WB_ADDR_LINK;
				reg_write = 1;
				is_link = 1;
			end
			INST_STOP: begin
				is_display = 1;
			end	
		endcase
	end
	
	// pipeline control
	reg reg_stall = 0;
	
	always @(*) begin
		reg_stall = 0;
		fwd_a = 0;
		fwd_b = 0;
		fwd_m = 0;
		if (rs_used && addr_rs != 0) begin
			if (addr_rs == write_reg_e && reg_write_e) begin
				if (is_load_e)
					reg_stall = 1;
				else
					fwd_a = 1;
			end 
			else if (addr_rs == write_reg_m && reg_write_m) begin
				if (is_load_m)
					fwd_a = 3;
				else
					fwd_a = 2;
			end
		end
		if (rt_used && addr_rt != 0) begin
			if (addr_rt == write_reg_e && reg_write_e) begin
				if (is_load_e) begin
					if (is_store)
						fwd_m = 1;
					else 
						reg_stall = 1;
				end
				else
					fwd_b = 1;
			end
			else if (addr_rt == write_reg_m && reg_write_m) begin
				if (is_load_m)
					fwd_b = 3;
				else
					fwd_b = 2;
			end
		end
	end
	
	always @(*) begin
		en_f = 1;
		en_d = 1;
		rst_d = 0;
		rst_e = 0;
		
		if (reg_stall) begin
			en_f = 0;
			en_d = 0;
			rst_e = 1;
		end
		else if (is_link) begin
			rst_d = 1;
		end
	end

endmodule
