//
// Created by 17119 on 2023/10/17.
//

#include "simulator.h"


Simulator::Simulator() : STACK_ADDR(0xA00000), START_ADDR(0x400000), STATIC_ADDR(0x500000), ASCII(".ascii"),
                         ASCIIZ(".asciiz"), Byte(".byte"), HALF(".half"), WORD(".word") {
    this->_regs = new unsigned int[35];
    this->_block = new unsigned char[0x600000];

    // register initialization
    _regs[$zero] = 0;
    _regs[$pc] = START_ADDR;
    _regs[$fp] = _regs[$sp] = STACK_ADDR;
    _regs[$gp] = STATIC_ADDR + 0x8000;  // points to the middle of a 64K block in the static data segment

}

Simulator::~Simulator() {
    delete[] _regs;
    delete[] _block;
}

void Simulator::_init(const string &inAsm, const string &inBin) {
    ifstream inA;
    ifstream inB;
    // data segment


    // text segment
    inB.open(inBin, ios::in);
    string inst;
    int count = 0;
    while (inB >> inst) {
        instructions.push_back(inst);
        for (int offset = 0; 4 > offset; offset++) {
            unsigned int bin = _strToNum(inst.substr(offset * 8, 9));
            this->_block[4 * count + 3 - offset] = bin;
        }
        count++;
    }
}

void Simulator::_rType(int rs, int rt, int rd, int sa, int func) {

};

void Simulator::_iType(int op, int rs, int rt, int imm) {

};

void Simulator::_jType(int op, int target) {

};

unsigned int Simulator::_strToNum(const string &s) {
    unsigned int res = 0;
    for (char c: s) {
        res = (res << 1) | (c - '0');
    }
    return res;
}

