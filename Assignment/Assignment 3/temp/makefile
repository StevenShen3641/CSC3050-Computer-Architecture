TARGET = ALU
test: compile; vvp $(TARGET)
compile: alu.v test_alu.v
		 iverilog -o ALU alu.v test_alu.v
clean:
	rm $(TARGET)
