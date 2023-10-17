#include "simulator.h"


void splitInstruct(string s, vector<string>& instruct, string type) { //split an MIPS instruction, ignore the trailing comment(if exists)
	if (type == ".asciiz" || type == ".ascii") {
		instruct.push_back(type); // just for consistency (with .word, .byte, .half)
		int begin = s.find_first_of("\"");
		int end = s.find_last_of("\"");
		instruct.push_back(s.substr(begin + 1, end - begin - 1));
	}
}

void eraseWhitespaces(string& s) {
	s.erase(0, s.find_first_not_of(" ")); // erase the leading whitespaces
	s.erase(0, s.find_first_not_of("\t"));
	s.erase(s.find_last_not_of(" ") + 1); // erase the trailing whitespaces
	s.erase(s.find_last_not_of("\t") + 1);
}

string getFirst(string s) { // get the first word of string s
	string result;
	for (int i = 0; i < s.size(); i++) {
		if (s[i] != ' ' && s[i] != '\n' && s[i] != '\t' && s[i] != '\0') {
			result += s[i];
		}
		else {
			break;
		}
	}
	return result;
}


Simulator::Simulator() {
	this->memory_pointer = (char *)calloc(0x600000, sizeof(char)); // allocate 0x600000 bytes memory
	this->pc = 0x400000; //initialize program counter to the first of the instruction
}

Simulator::~Simulator() {
	free(this->memory_pointer);
}

void Simulator::i_type(int instruction) {
	uint32_t instruct = static_cast<uint32_t>(instruction);
	int op = (instruct >> 26) & 0x3F;
	int rs = (instruct >> 21) & 0x1F;
	int rt = (instruct >> 16) & 0x1F;
	int im = instruct & 0xFFFF;

	switch (op) {
		case 0x08:
			addi(rs, rt, im);
			break;
	}
}

int Simulator::im_sign_extend(int im) {
	int result = 0;
	if (im >> 15) {
		result = im | 0xFFFF0000; //signed bit = 1
	}
	else {
		result = im; //signed bit = 0
	}
	return result;
}

void Simulator::addi(int rs, int rt, int im) {
	int signed_ex = im_sign_extend(im);
	if (im < 0) {
		cout << "signed extend = " << signed_ex << endl;
	}
	this->reg[rt] = this->reg[rs] + signed_ex;
}

void Simulator::r_type(int instruction, ifstream &ioIn, ofstream &ioOut) {
	uint32_t instruct = static_cast<uint32_t>(instruction);
	int rs = (instruct >> 21) & 0x1F;
	int rt = (instruct >> 16) & 0x1F;
	int rd = (instruct >> 11) & 0x1F;
	int sa = (instruct >> 6) & 0x1F;
	int funct = instruct & 0x3F;

	switch (funct) {
		case 0x00:
			sll(rt, rd, sa);
			break;

		case 0x0C:
			syscall(ioIn, ioOut);
			break;

	}
}

void Simulator::sll(int rt, int rd, int sa) {
	this->reg[rd] = this->reg[rt] << sa;
}

void Simulator::syscall(ifstream& ioIn, ofstream& ioOut) {
	int v0 = this->reg[$v0];

	if (v0 == 4){ //print_string
		uint32_t addr = static_cast<uint32_t>(this->reg[$a0]);
		int i = 0;
		while (this->memory_pointer[addr + i - BASE_ADDR] != '\0') { //read the null-terminated string, beginning at addr
			ioOut << this->memory_pointer[addr + i - BASE_ADDR];
			i++;
		}
		ioOut << flush;
	}
}

void Simulator::store(string asm_in, string bin_in) {
	ifstream asmIn;
	ifstream binIn;

	asmIn.open(asm_in.c_str(), ios::in);
	binIn.open(bin_in.c_str(), ios::in);

	if (asmIn.fail() || binIn.fail()) {
		cout << "Error (store): input files not open correctly" << endl;
		exit(1);
	}
	else {
		this->storeAsm(asmIn);
		this->storeBin(binIn);
	}
	asmIn.close();
	binIn.close();
}

void Simulator::storeAsm(ifstream& asmFile) { 
	string s;
	bool flag = false; // if current line is in .data section
	int block = 0; //current No. of 4-byte block num in virtual static memory
	while (getline(asmFile, s)) {
		eraseWhitespaces(s);
		if (!s.empty()) { // ignore blank line with leading whitespace
			if (s[0] != '#' && s[0] != '\n') {
				string first = getFirst(s);
				if (first == ".data") {
					flag = true;
					continue;
				}
				if (first == ".text") {
					flag = false;
					continue;
				}
				if (flag) { // in .data section
					int colon_pos = s.find_first_of(":");
					if (colon_pos != -1) {
						s.erase(0, colon_pos + 1); // ignore data label
						eraseWhitespaces(s);
					}
					if (!s.empty() && s[0] != '#') {
						string type = getFirst(s);
						vector<string> instruct; //instruct[0] stores the data type
						splitInstruct(s, instruct, type);

						int block_needed = 0;
						if (type == ".asciiz" || type == ".ascii") { 
							string content = instruct[1];
							if (type == ".asciiz") {
								content += '\0';
							}
							int len = content.length();
							block_needed = (len % 4 == 0) ? (len / 4) : (len / 4 + 1);
							for (int i = 0; i < len; i++) {
								this->memory_pointer[STATIC_ADDR - BASE_ADDR + block * 4 + i] = content[i];
							}
						}
						block += block_needed;

					}
				}
			}
		}
	}
	this->dynamicEnd = STATIC_ADDR + block * 4; //start of dynamic = end of dynamic
}

void Simulator::storeBin(ifstream& binFile) { //store machine code input
	string s;
	int count = 0; //count the number of instructions (for calculating address)
	while (getline(binFile, s)) {
		bitset<32> bit(s);
		unsigned int instruction = bit.to_ulong();
		for (int i = 0; i < 4; i++) {
			this->memory_pointer[count * 4 + i] = (instruction >> 8 * i) & 0xff;
		}
		count++;
	}
}

bool Simulator::pc_is_valid() {
	if (this->pc >= BASE_ADDR && this->pc < STATIC_ADDR) {
		return true;
	}
	else {
		return false;
	}
}

int Simulator::fetch(uint32_t pc) { //fetch the 4 bytes starting at pc and convert it to binary string
	int result = ((int)this->memory_pointer[pc - BASE_ADDR]) & (0xff) | (((int)this->memory_pointer[pc+1-BASE_ADDR]) & (0xff)) << 8 | \
		(((int)this->memory_pointer[pc+2-BASE_ADDR]) & 0xff) << 16 | (((int)this->memory_pointer[pc+3-BASE_ADDR]) & 0xff) << 24;

	return result;
}

void Simulator::execute(int instruction, ifstream & ioIn, ofstream & ioOut) {
	int opcode = ((static_cast<uint32_t>(instruction)) >> 26) & 0x3F;
	if (opcode == 0) {
		r_type(instruction, ioIn, ioOut);
	}
	else {
		i_type(instruction);
	}
}

