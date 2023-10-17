#include "simulator.h"

int main(int argc, char ** argv) {
	if (argc < 6) {
		printf("Please enter an input file of assembly codes, an input file of assembled binary codes, checkpoints, inputs for read-related IO operations, and output file for print-related IO operations\n");
		return 0;
	}

	Simulator simulator; //initialize the registers and empty virtual memory

	Checkpoints checkpoints(argv[3]);

	//store the instruction and data(.data section(in static), string handling needed)
	simulator.store(argv[1], argv[2]); 

	ifstream ioIn;
	ofstream ioOut;
	ioIn.open(argv[4], ios::in);
	ioOut.open(argv[5], ios::out);

	int ins_count = 0;
	while (true) {
		if (!simulator.pc_is_valid()) {
			break;
		}

		checkpoints.dump(ins_count, simulator);

		int instruction = simulator.fetch(simulator.pc);
		simulator.pc += 4;
		simulator.execute(instruction, ioIn, ioOut);
		ins_count++;
	}
	ioIn.close();
	ioOut.close();
	return 0;
}