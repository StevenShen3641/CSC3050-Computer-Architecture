//
// Created by 17119 on 2023/10/17.
//

#ifndef SIMULATOR_H
#define SIMULATOR_H

#include <iostream>
#include <string>

using namespace std;

class Simulator {
public:
    Simulator();

    ~Simulator();

private:
    // variable
    unsigned int *_regs;
    unsigned char *_block;


    // constant
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

    // initialization
    void _init();

    // methods
    void _rType(int rs, int rt, int rd, int sa, int funct);

    void _iType(int op, int rs, int rt, int imm);

    void _jType(int op, int target);


};


#endif //SIMULATOR_H
