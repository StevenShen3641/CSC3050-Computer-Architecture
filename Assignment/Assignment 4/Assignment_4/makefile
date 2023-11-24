VcdFile  = test
ElfFile  = run
all:compile visual sim
compile:
	iverilog -o run.out test_CPU.v CPU.v
visual:
	vvp -n $(ElfFile).out
sim:
	gtkwave $(VcdFile).vcd
clean:
	rm -rf *vcd *.out

