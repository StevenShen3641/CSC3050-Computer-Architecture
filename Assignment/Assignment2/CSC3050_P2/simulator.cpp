//
// Created by 17119 on 2023/10/17.
//

#include "simulator.h"


Simulator::Simulator() : STACK_ADDR(0xA00000), START_ADDR(0x400000), STATIC_ADDR(0x500000), ASCII(".ascii"),
                         ASCIIZ(".asciiz"), Byte(".byte"), HALF(".half"), WORD(".word") {
    _regs = new unsigned int[35];
    _block = new unsigned char[0x600000];
}

Simulator::~Simulator() {
    delete[] _regs;
    delete[] _block;
}

void Simulator::_init() {

}

void Simulator::_rType(int rs, int rt, int rd, int sa, int func) {

};

void Simulator::_iType(int op, int rs, int rt, int imm) {

};

void Simulator::_jType(int op, int target) {

};

