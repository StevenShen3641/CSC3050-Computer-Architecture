#ifndef _SIMULATOR_H
#define _SIMULATOR_H

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <cstdint>
#include <bitset>
#include <set>
#include <cstdio>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BASE_ADDR 0x400000
#define STATIC_ADDR 0x500000 // start of static data segment (virtual)
#define HIGHEST_ADDR 0xA00000 // end of virtual memory (start of stack segment)

using namespace std;

enum regNum {  //register number
	$zero,
	$at, //reserved for assembler
	$v0, $v1,
	$a0, $a1, $a2, $a3,
	$t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7,
	$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7,
	$t8, $t9,
	$k0, $k1, //reserved for os
	$gp,
	$sp,
	$fp, //frame pointer (same)
	$ra
};

struct Simulator {
	char* memory_pointer; //memory pointer to start of actual memory, used for malloc
	//map<string, int>regNo; // store <regName, regNo.> pair
	vector<int32_t> reg = vector<int32_t>(32, 0); //0-31 registers, index: register.no; value: register value, initialized to 0
	uint32_t pc;
	int32_t hi;
	int32_t lo;

	uint32_t dynamicEnd; //the end address of dynamic data


	Simulator();
	~Simulator();

	//void init_reg_map(); //initialize the regNo map (stores <regName, regNo.> pair)

	void store(string asm_in, string bin_in);
	void storeAsm(ifstream& asmFile);
	void storeBin(ifstream& binFile);

	bool pc_is_valid();

	int fetch(uint32_t pc);
	void execute(int instruction, ifstream & ioIn, ofstream & ioOut);

	void r_type(int instruction, ifstream & ioIn, ofstream & ioOut);
	void i_type(int instruction);

	void sll(int rt, int rd, int sa);
	int im_sign_extend(int im);
	void addi(int rs, int rt, int im);
        void syscall(ifstream& ioIn, ofstream& ioOut);
};

struct Checkpoints {
	set<int> checkpoints;

	Checkpoints() {};
	Checkpoints(string file);
	void dump(int ins_count, const Simulator &simulator);
};

// other functions
void splitInstruct(string s, vector<string>& instruct, string type);
void eraseWhitespaces(string& s);
string getFirst(string s);
string toLower(string s);
void modify_special(string& s);

#endif
