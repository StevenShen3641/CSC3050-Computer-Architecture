test:compile; vvp CPU;

compile: cpu.v test_cpu.v
		 iverilog -o CPU cpu.v test_cpu.v IF.v ID.v EX.v MEM.v WB.v Hazard.v