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

    /// initialization
    /// \param inAsm input asm file
    /// \param inBin input binary code file
    void init(const string &inAsm, const string &inBin);

    /// simulation part
    /// \param inFile input file
    /// \param outFile output file
    void simulate(const string &inFile, const string &outFile);

private:
    // variables
    unsigned int *_regs;
    unsigned char *_block;
    int staticDataPos;  /// need to be check
    ifstream inF;
    ofstream outF;

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

    // fetch machine code
    string _fetchCode(unsigned int pc);

    // methods
    void _rType(string rs, string rt, string rd, string sa, string func);

    void _iType(string op, string rs, string rt, string imm);

    void _jType(string op, string target);

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
