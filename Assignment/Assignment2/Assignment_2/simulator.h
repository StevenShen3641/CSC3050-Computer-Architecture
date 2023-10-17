#ifndef MY_SIMULATOR_H
#define MY_SIMULATOR_H
#include "LabelTable.h"
#include "util.h"
#include <set>
#include <fstream>
#include <string>
#include <vector>

typedef unsigned char byte;
#define MAX_MEM_SIZE 0x600000 /* 6MB */
#define MEM_BIAS 0x400000
#define TEXT_SEG_SIZE 0x100000

enum REGS {
    _zero, _at, _v0, _v1, _a0, _a1, _a2, _a3,
    _t0, _t1, _t2, _t3, _t4, _t5, _t6, _t7,
    _s0, _s1, _s2, _s3, _s4, _s5, _s6, _s7,
    _t8, _t9, _k0, _k1, _gp, _sp, _fp, _ra,
    _pc, _hi, _lo
};

class Simulator
{
public:
    Simulator(std::string _inputAsm, std::string _inputBin, std::string _outputCheckPts, std::string _inFile, std::string _outFile);
    ~Simulator();

    int run();

private:
    LabelTable labelTable;
    std::string outputCheckPts;
    std::string inputAsm;
    std::string inFile;
    std::string outFile;
    std::ifstream fin;
    std::ofstream fout;
    std::set<int> checkpoints;
    std::vector<std::string> insts;
    uint32 reg[REG_CNT + 3];
    byte mem[MAX_MEM_SIZE];

    void preprocess();
    void execute(std::string inst);
    void parseInst(std::string inst);

    static std::string ASCII;
    static std::string ASCIIZ;
    static std::string BYTE;
    static std::string HALF;
    static std::string WORD;

    /* State of current instruction */
    int opCode, rs, rt, rd, sa, funct, imm, target;
    INST_TYPE instType;

    /* Functions corresponding to all instructions */
    void _add();
    void _addu();
    void _and();
    void _div();
    void _divu();
    void _jalr();
    void _jr();
    void _mfhi();
    void _mflo();
    void _mthi();
    void _mtlo();
    void _mult();
    void _multu();
    void _nor();
    void _or();
    void _sll();
    void _sllv();
    void _slt();
    void _sltu();
    void _sra();
    void _srav();
    void _srl();
    void _srlv();
    void _sub();
    void _subu();
    void _syscall();
    void _xor();
    void _addi();
    void _addiu();
    void _andi();
    void _beq();
    void _bgez();
    void _bgtz();
    void _blez();
    void _bltz();
    void _bne();
    void _lb();
    void _lbu();
    void _lh();
    void _lhu();
    void _lui();
    void _lw();
    void _ori();
    void _sb();
    void _slti();
    void _sltiu();
    void _sh();
    void _sw();
    void _xori();
    void _lwl();
    void _lwr();
    void _swl();
    void _swr();
    void _j();
    void _jal();

    /* System calls */
    void _print_int();
    void _print_string();
    void _read_int();
    void _read_string();
    void _sbrk();
    void _exit();
    void _print_char();
    void _read_char();
    void _open();
    void _read();
    void _write();
    void _close();
    void _exit2();

    void dumpReg(int instCount);
    void dumpMem(int instCount);

    int memUsed;

    int returnValue = 0;
    bool shouldReturn = false;
};

#endif
