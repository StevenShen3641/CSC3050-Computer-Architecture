TARGET = CPU
test:compile; vvp $(TARGET);
compile: cpu.v test_cpu.v
		 iverilog -o $(TARGET) cpu.v test_cpu.v IF.v ID.v EX.v MEM.v WB.v Hazard.v
clean:
	rm $(TARGET)