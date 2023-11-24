`include "alu.v"
`include "CONTROLL_UNIT.v"
`include "InstructionRAM.v"
`include "MainMemory.v"
`include "RegisterFile.v"
module CPU(
	input wire clk,
	input wire rst_f
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
	
	// clock signal
	reg [11:0] clk_count = 12'b0;
	reg flag = 1'b0;
	// IF signals
	wire en_f;
	
	wire [31:0] pc_f;
	wire [31:0] rd;
	wire [31:0] pc_plus4_f;
	reg [31:0] pc_reg;
	
	// ID signals
	wire en_d;
	wire rst_d;
	
	reg [31:0] instr_d;
	reg [31:0] pc_d;
	reg [31:0] pc_plus4_d;
	wire rs_rt_equal;
	wire reg_write_d;
	wire mem_to_reg_d;
	wire mem_write_d;
	wire mem_used_d;
	wire is_display_d;
	wire [3:0] ALU_control_d;
	wire [1:0] ALU_src_A_d;
	wire [1:0] ALU_src_B_d;	
	wire [1:0] reg_dst_d;
	wire ext_sign_d;
	wire is_load_d;
	wire [1:0] pc_src_d;
	wire [1:0] fwd_a_d;
	wire [1:0] fwd_b_d;
	wire fwd_m_d;
 	
	wire [31:0] rd1_d;
	wire [31:0] rd2_d;
	wire [31:0] ext_imm_d;
	wire [31:0] ext_shamt_d;
	reg [31:0] rd1_fwd;
	reg [31:0] rd2_fwd;
	
	// EXE signals
	wire rst_e;
	
	reg reg_write_e;
	reg mem_to_reg_e;
	reg mem_write_e;
	reg mem_used_e;
	reg [3:0] ALU_control_e;
	reg [1:0] ALU_src_A_e;
	reg [1:0] ALU_src_B_e;
	reg [1:0] reg_dst_e;
	reg [31:0] rd1_e;
	reg [31:0] rd2_e;
	reg [4:0] rt_e;
	reg [4:0] rd_e;
	reg [31:0] ext_imm_e;
	reg [31:0] ext_shamt_e;
	reg [31:0] src_A_e;
	reg [31:0] src_B_e;
	reg [4:0] write_reg_e;
	reg is_load_e;
	reg [1:0] fwd_a_e;
	reg [1:0] fwd_b_e;
	reg fwd_m_e;
	reg [31:0] pc_plus4_e;
	reg is_display_e;
	wire [31:0] write_data_e;	
	wire [31:0] ALU_out_e;
	wire [2:0] flags;
	
	// MEM signals
	reg reg_write_m;
	reg mem_to_reg_m;
	reg mem_write_m;
	reg mem_used_m;
	reg zero_m;
	reg [31:0] ALU_out_m;
	reg [31:0] write_data_m;
	reg [4:0] write_reg_m;
	reg is_load_m;
	reg is_display_m;
	reg fwd_m_m;
	wire [31:0] read_data_m;
	
	// WB signals
	reg reg_write_w;
	reg mem_to_reg_w;
	reg [31:0] ALU_out_w;
	reg [31:0] read_data_w;
	reg [4:0] write_reg_w;
	wire [31:0] result_w;
	integer file_out;
	// clock count
	always @ (posedge clk) begin
		clk_count <= clk_count + 1;
	end

	// IF stage
	assign pc_f = pc_reg;
	assign pc_plus4_f = pc_f + 4;
	
	InstructionRAM instruction_RAM(
		.CLOCK(clk),
		.FETCH_ADDRESS(pc_f >> 2),
		.ENABLE(1'b1),
		.DATA(rd)
	);
	
	always @(posedge clk) begin
		if (rst_f) begin
			pc_reg <= 32'b0;
		end
		else if (en_f) begin
			case (pc_src_d)
				PC_PLUS4: pc_reg <= pc_plus4_f;
				PC_JUMP: pc_reg <= {pc_d[31:28], instr_d[25:0], 2'b0};
				PC_JR: pc_reg <= rd1_fwd;
				PC_BRANCH: pc_reg <= pc_plus4_d + {ext_imm_d[29:0], 2'b0};
			endcase
		end
	end
	
	// ID stage
	always @(posedge clk) begin	// regs between IF and ID
		if (rst_d) begin
			instr_d <= 0;
			pc_d <= 0;
			pc_plus4_d <= 0;
		end
		else if (en_d) begin
			instr_d <= rd;
			pc_d <= pc_f;
			pc_plus4_d <= pc_plus4_f;
		end
	end
	
	ControlUnit control_unit(
		.op(instr_d[31:26]),
		.addr_rs(instr_d[25:21]),
		.addr_rt(instr_d[20:16]),
		.funct(instr_d[5:0]),
		.rs_rt_equal(rs_rt_equal),
		.write_reg_e(write_reg_e),
		.reg_write_e(reg_write_e),
		.is_load_e(is_load_e),
		.write_reg_m(write_reg_m),
		.reg_write_m(reg_write_m),
		.is_load_m(is_load_m),
		.reg_write(reg_write_d),
		.mem_to_reg(mem_to_reg_d),
		.mem_write(mem_write_d),
		.mem_used(mem_used_d),
		.pc_src(pc_src_d),
		.ALU_control(ALU_control_d),
		.ALU_src_A(ALU_src_A_d),
		.ALU_src_B(ALU_src_B_d),
		.reg_dst(reg_dst_d),
		.ext_sign(ext_sign_d),
		.is_load(is_load_d),
		.fwd_a(fwd_a_d),
		.fwd_b(fwd_b_d),
		.fwd_m(fwd_m_d),
		.en_f(en_f),
		.en_d(en_d),
		.rst_d(rst_d),
		.rst_e(rst_e),
		.is_display(is_display_d)
	);
	
	RegisterFile register_file(
		.clk(clk),
		.a1(instr_d[25:21]),
		.a2(instr_d[20:16]),
		.a3(write_reg_w),
		.rd1(rd1_d),
		.rd2(rd2_d),
		.we3(reg_write_w),
		.wd3(result_w)
	);
	
	assign ext_imm_d = (ext_sign_d == 0) ? {16'b0,instr_d[15:0]} : {{16{instr_d[15]}},instr_d[15:0]};
	assign ext_shamt_d = {27'b0,instr_d[10:6]};
	
	always @(*) begin
		rd1_fwd = rd1_d;
		rd2_fwd = rd2_d;
		case (fwd_a_d)
			0: rd1_fwd = rd1_d;
			1: rd1_fwd = ALU_out_e;
			2: rd1_fwd = ALU_out_m;
			3: rd1_fwd = read_data_m;
		endcase
		case (fwd_b_d)
			0: rd2_fwd = rd2_d;
			1: rd2_fwd = ALU_out_e;
			2: rd2_fwd = ALU_out_m;
			3: rd2_fwd = read_data_m;
		endcase
	end
	
	assign rs_rt_equal = (rd1_fwd == rd2_fwd) ? 1 : 0;
	
	always @ (posedge clk) begin
		if (is_display_d && ~flag) begin
			$display("                         clock cycle = %4d\n" , clk_count+2);
			flag <= 1'b1;
		end
	end
	
	// EXE stage
	always @(posedge clk) begin	// regs between ID and EXE
		if (rst_e) begin
			reg_write_e <= 0;
			is_load_e <= 0;
			mem_to_reg_e <= 0;
			mem_write_e <= 0;
			mem_used_e <= 0;
			is_display_e <= 0;
			ALU_control_e <= 0;
			ALU_src_A_e <= 0;
			ALU_src_B_e <= 0;
			reg_dst_e <= 0;
			rd1_e <= 0;
			rd2_e <= 0;
			ext_imm_e <= 0;
			ext_shamt_e <= 0;
			rt_e <= 0;
			rd_e <= 0;
			fwd_a_e <= 0;
			fwd_b_e <= 0;
			fwd_m_e <= 0;
			pc_plus4_e <= 0;
		end
		else begin
			reg_write_e <= reg_write_d;
			is_load_e <= is_load_d;
			mem_to_reg_e <= mem_to_reg_d;
			mem_write_e <= mem_write_d;
			mem_used_e <= mem_used_d;
			ALU_control_e <= ALU_control_d;
			ALU_src_A_e <= ALU_src_A_d;
			ALU_src_B_e <= ALU_src_B_d;
			reg_dst_e <= reg_dst_d;
			rd1_e <= rd1_fwd;
			rd2_e <= rd2_fwd;
			ext_imm_e <= ext_imm_d;
			ext_shamt_e <= ext_shamt_d;
			rt_e <= instr_d[20:16];
			rd_e <= instr_d[15:11];
			fwd_a_e <= fwd_a_d;
			fwd_b_e <= fwd_b_d;
			fwd_m_e <= fwd_m_d;
			pc_plus4_e <= pc_plus4_d;
			is_display_e <= is_display_d;
		end
	end
	
	always @ (*) begin
		case (ALU_src_A_e)
			EXE_A_RS: src_A_e = rd1_e;
			EXE_A_SA: src_A_e = ext_shamt_e;
			EXE_A_LINK: src_A_e = pc_plus4_e;
		endcase
		case (ALU_src_B_e)
			EXE_B_RT: src_B_e = rd2_e;
			EXE_B_IMM: src_B_e = ext_imm_e;
			EXE_B_LINK: src_B_e = 32'b0;
		endcase
		case (reg_dst_e)
			WB_ADDR_RT: write_reg_e = rt_e;
			WB_ADDR_RD: write_reg_e = rd_e;
			WB_ADDR_LINK: write_reg_e = GPR_RA;
		endcase
	end
	
	assign write_data_e = rd2_e;
	 
	ALU alu(
		.a(src_A_e),
		.b(src_B_e),
		.ALU_control(ALU_control_e),
		.result(ALU_out_e),
		.flags(flags)
	);
	
	// MEM stage
	always @(posedge clk) begin	// regs between EXE and MEM
		reg_write_m <= reg_write_e;
		mem_to_reg_m <= mem_to_reg_e;
		mem_write_m <= mem_write_e;
		mem_used_m <= mem_used_e;
		is_display_m <= is_display_e;
		zero_m <= flags[2];
		ALU_out_m <= ALU_out_e;
		write_reg_m <= write_reg_e;
		is_load_m <= is_load_e;
		fwd_m_m <= fwd_m_e;
		write_data_m <= fwd_m_m ? result_w : write_data_e;
	end
	

	MainMemory main_memory(
		.CLOCK(clk),
		.ENABLE(mem_used_m),
		.FETCH_ADDRESS(ALU_out_m>>2),
		.EDIT_SERIAL({mem_write_m,ALU_out_m>>2,write_data_m}),
		.IS_DISPLAY(is_display_m),
		.DATA(read_data_m)
	);
	
	// WD stage
	always @(posedge clk) begin	// regs between MEM and WD
		reg_write_w <= reg_write_m;
		mem_to_reg_w <= mem_to_reg_m;
		ALU_out_w <= ALU_out_m;
		read_data_w <= read_data_m;
		write_reg_w <= write_reg_m;
	end
	
	assign result_w = (mem_to_reg_w == 0) ? ALU_out_w : read_data_w;

endmodule
