#include "simulator.h"

Checkpoints::Checkpoints(string file) {
	FILE* fp = fopen(file.c_str(), "r");
	if (fp == NULL) {
		cout << "error: Not able to open checkpoints txt file!" << endl;
		exit(1);
	}
	int tmp, i = 0;
	while (fscanf(fp, "%d", &tmp) != EOF) {
		this->checkpoints.insert(tmp);
	}
	fclose(fp);
}

void Checkpoints::dump(int ins_count, const Simulator &simulator) {
	if (!this->checkpoints.count(ins_count)) {
		return;
	}
	/* Dump memory */
	string memory = "memory_" + to_string(ins_count) + ".bin";
	FILE* fp1 = fopen(memory.c_str(), "wb");
	fwrite(simulator.memory_pointer, 1, 0x600000, fp1);
	fclose(fp1);
	/* Dump register */
	string reg = "register_" + to_string(ins_count) + ".bin";
	FILE* fp2 = fopen(reg.c_str(), "wb");

	for (int i = 0; i < 32; i++) { // for simulator.reg 0-31 registers
		fwrite(&(simulator.reg[i]), 4, 1, fp2);
	}
	fwrite(&(simulator.pc), 4, 1, fp2);
	fwrite(&(simulator.hi), 4, 1, fp2);
	fwrite(&(simulator.lo), 4, 1, fp2);
	fclose(fp2);
}