module alu(instruction, regA, regB, result, flags);
	input[31:0] instruction;
	input[31:0] regA,regB; 
	output[31:0] result;
	output[2:0] flags; 

	reg[5:0] opcode, func; // store the operator code and the function code
	reg[31:0] rd; // store the computing result
	reg[31:0] rs,rt; //store the operator number
	reg[5:0] shamt;
	reg[15:0] imm;
	reg[2:0] flags;
	reg[31:0] temp;
	reg[31:0] tempA;
	reg[31:0] tempB;
	always @ (*)
		begin
		tempA = regA;
		tempB = regB;
		opcode = instruction[31:26];
		func = instruction[5:0];
		flags = 3'b000;
		if(instruction[20:16]=={5'b0})
			begin
			temp = tempA;
			tempA = tempB;
			tempB = temp;
			end
		case(opcode)
		6'b000000:
			begin
				case(func)

					//add
					6'b100000:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs + rt;
							if({rs[31],rt[31],rd[31]}=={3'b001}||{rs[31],rt[31],rd[31]}=={3'b110})
								flags[0] = 1;
							else 
								flags[0] = 0;
							
						end

					//addu
					6'b100001:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs + rt;

						end

					//sub
					6'b100010:
						begin
							rs = tempA;
							rt = tempB;
							rd = tempA - tempB;
							if({rs[31],rt[31],rd[31]}=={3'b011}||{rs[31],rt[31],rd[31]}=={3'b100})
								flags[0] = 1;
							else
								flags[0] = 0;
						end

					//subu
					6'b100011:
						begin
							rs = tempA;
							rt = tempB;
							rd = tempA - tempB;
						end

					//and
					6'b100100:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs & rt;
						end

					//nor
					6'b100111:
						begin
							rs = tempA;
							rt = tempB;
							rd = ~(rs | rt);
						end 	

                    //or
					6'b100101:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs | rt;
						end		
					
					//xor
					6'b100110:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs ^ rt;
						end		
					
					//slt
					6'b101010:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs - rt;
							flags[1] = rd[31];  
						end

					//sltu
					6'b101011:
						begin
							rs = tempA;
							rt = tempB;
							rd = rs - rt;
							flags[1] = (rs<rt);
						end

					//sll
					6'b000000:
						begin
							rt = tempB;
							shamt = instruction[10:6];
							rd = rt << shamt;
						end
					
					//sllv
					6'b000100:
						begin
							rs = tempA;
							rt = tempB;
							rd = rt << rs;
						end
							
					//srl
					6'b000010:
						begin
							rt = tempB;
							shamt = instruction[10:6];
							rd = rt >> shamt;
						end

					//srlv
					6'b000110:
						begin
							rs = tempA;
							rt = tempB;
							rd = rt >> rs;
						end

					//sra
					6'b000011:
						begin
							rt = tempB;
							shamt = instruction[10:6];
							rd = rt >>> shamt;
						end

					//srav
					6'b000111:
						begin
							rs = tempA;
							rt = tempB;
							rd = rt >>> rs;
						end

					endcase
				end
			
			//addi
			6'b001000:
				begin
					rs = tempA;
					imm = instruction[15:0];
					if(imm[15] == 1'b1)
					     rd = rs + {16'b1,imm};
					
					else 
					     rd = rs + {16'b0,imm};
					
					if({rs[31],rd[31]}=={2'b01} || {rs[31],rd[31]} == {2'b10})
						flags[0] = 1;
					else 
						flags[0] = 0;
				end

			//addiu
			6'b001001:
				begin
					rs = tempA;
					imm = instruction[15:0];
					rd = rs + {16'b0,imm};

				end

			//andi
			6'b001100:
				begin
					rs = tempA;
					imm = instruction[15:0];
					rd = rs & {16'b0,imm};
				end

			//beq
			6'b000100:
				begin
					rs = tempA;
					rt = tempB;
					rd = rs - rt;
					if(rd=={32'b0})
						flags[2] = 1;
					else
						flags[2] = 0;
				end

			//bne
			6'b000101:
				begin
					rs = tempA;
					rt = tempB;
					rd = rs - rt;
					if(rd=={32'b0})
						flags[2] = 1;
					else
						flags[2] = 0;
				end
			
			//ori
			6'b001101:
				begin
					rs = tempA;
					imm = instruction[15:0];
					rd = rs | {16'b0,imm};
				end	

			//xori
			6'b001110:
				begin
					rs = tempA;
					imm = instruction[15:0];
					rd = rs ^ {16'b0,imm};
				end

			//slti
			6'b001010:
				begin
					rs = tempA;
					imm = instruction[15:0];
					if (imm[15] == 1'b0)
						rd = rs - {16'b0,imm};
					else 
						rd = rs - {16'b1,imm};
					flags[1] = rd[31];
				end

			//sltiu
			6'b001011:
				begin
					rs = tempA;
					imm = instruction[15:0];
					rd = rs - {16'b0,imm};
					flags[1] = (rs<{16'b0,imm});
				end

			//lw
			6'b100011:
				begin
					rs = tempA;
					imm = instruction[15:0];
					if (imm[15] == 1'b0)
					rd = rs + {16'b0,imm};
					
					else 
					rd = rs + {16'b1,imm};
					
					
				end				

			//sw
			6'b101011:
				begin
					rs = tempA;
					imm = instruction[15:0];
					if (imm[15] == 1'b0)
					rd = rs + {16'b0,imm};
					
					else 
					rd = rs + {16'b1,imm};
					
				
				end
			
			endcase
		end
	
	assign result = rd[31:0];

endmodule
