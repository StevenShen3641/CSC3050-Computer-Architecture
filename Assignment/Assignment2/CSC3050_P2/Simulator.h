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
#include <sstream>
#include <bitset>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "Checkpoints.h"

#define REG_NUM  35

using namespace std;

typedef long long ll;  // 64-bit
typedef unsigned long long ull;  // 64-bit unsigned

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

    /// initialization
    /// \param inAsm input asm file
    /// \param inBin input binary code file
    void init(const string &inAsm, const string &inBin, const string &checkPts);

    /// simulation part
    /// \param inFile input file
    /// \param outFile output file
    void simulate(const string &inFile, const string &outFile);

private:
    // variables
    unsigned int *_regs;
    unsigned char *_block;
    int staticDataPos;
    ifstream inF;
    ofstream outF;
    Checkpoints cp;
    bool re;
    int reCode;

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
    const string BYTE;

    // methods
    // fetch machine code
    string _fetchCode(unsigned int pc);

    void _execute(const string& inst);

    void _rType(unsigned int rs, unsigned int rt, unsigned int rd, unsigned int sa, unsigned int func);

    void _syscall();

    void _iType(unsigned int op, unsigned int rs, unsigned int rt, unsigned int imm);

    void _jType(unsigned int op, unsigned int target);

};

// other relative functions
/// binary string to corresponding binary number
/// \param s binary string
/// \return unsigned integer containing binary number
unsigned int strToNum(const string &s);

/// remove comments
/// \param s input string
/// \return string without comments
string removeComments(string s);

/// remove blank space, '\t', '\n', .etc of string
/// \param s input string
/// \return trimmed string
string trim(string s);

/// change input string into escaped version
/// \param s input string
/// \return escaped version
string escape(string s);


#endif //SIMULATOR_H
