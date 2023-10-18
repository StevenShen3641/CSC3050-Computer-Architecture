//
// Created by 17119 on 2023/10/17.
//

#ifndef SIMULATOR_H
#define SIMULATOR_H

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstring>

#define REG_NUM  35

using namespace std;

// registers index
enum REGS {
    $zero,
    $at,
    $v0, $v1,
    $a0, $a1, $a2, $a3,
    $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7,
    $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7,
    $t8, $t9,
    $k0, $k1,
    $gp,
    $sp,
    $fp,
    $ra,
    $pc, $hi, $lo
};

class Simulator {
public:
    Simulator();

    ~Simulator();

    // initialization
    void init(const string &inAsm, const string &inBin);

private:
    // variables
    unsigned int *_regs;
    unsigned char *_block;
    vector<string> instructions;


    // constants
    // address
    const int START_ADDR;
    const int STATIC_ADDR;
    const int STACK_ADDR;
    // data type
    const string ASCII;
    const string ASCIIZ;
    const string WORD;
    const string HALF;
    const string Byte;

    // methods
    void _rType(int rs, int rt, int rd, int sa, int func);

    void _iType(int op, int rs, int rt, int imm);

    void _jType(int op, int target);

};

// other relative functions
unsigned int strToNum(const string &s);

string trim(string s);

vector<string> typeDataSplit(const string& s);



#endif //SIMULATOR_H
