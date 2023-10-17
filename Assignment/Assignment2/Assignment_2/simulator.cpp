#include "simulator.h"
#include <sstream>
#include <iostream>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>

std::string Simulator::ASCII = ".ascii";
std::string Simulator::ASCIIZ = ".asciiz";
std::string Simulator::BYTE = ".byte";
std::string Simulator::HALF = ".half";
std::string Simulator::WORD = ".word";

Simulator::Simulator(std::string _inputAsm, std::string _inputBin, std::string _outputCheckPts, std::string _inFile, std::string _outFile) {
    std::stringstream ss;
    labelTable.pass1(_inputAsm);
    labelTable.pass2(_inputAsm, ss);
    
    std::string inst;
    while (ss >> inst) {
        insts.push_back(inst);
    }

    inputAsm = _inputAsm;
    outputCheckPts = _outputCheckPts;
    inFile = _inFile;
    outFile = _outFile;

    for (int i = 0; i < REG_CNT + 3; i++) {
        reg[i] = 0;
    }
    memset(mem, 0, sizeof(mem));
}

Simulator::~Simulator() {
    fin.close();
    fout.close();
}

int Simulator::run() {
    /* Initialize memory and checkpoints */
    preprocess();

    /* Initialize registers */
    reg[_pc] = MEM_BIAS;
    reg[_gp] = MEM_BIAS + TEXT_SEG_SIZE + 0x8000; /* 32KB above the beginning of the static data section */
    reg[_sp] = reg[_fp] = MEM_BIAS + MAX_MEM_SIZE;

    /* Initialize IO */
    fin.open(inFile);
    fout.open(outFile);

    /* Begin simulation */
    int idx = 0, totalInstCnt = 0;
    while (idx >= 0 and idx < insts.size()) {
        if (checkpoints.count(totalInstCnt)) {
            dumpReg(totalInstCnt);
            dumpMem(totalInstCnt);
        }
        if (shouldReturn) {
            break;
        }
        auto inst = insts[idx];
        reg[_pc] += 4;
        /* Execute the instruction */
        execute(inst);
        idx = (reg[_pc] - MEM_BIAS) >> 2;
        totalInstCnt++;
    }
    
    if (checkpoints.count(totalInstCnt)) {
        dumpReg(totalInstCnt);
        dumpMem(totalInstCnt);
    }

    fin.close();
    fout.close();

    return returnValue;
}

void Simulator::execute(std::string inst) {
    /* Parse the instruction */
    parseInst(inst);
    switch (instType) {
        case R_TYPE:
            switch (funct) {
                case 0b100000:
                    _add();
                    break;
                case 0b100001:
                    _addu();
                    break;
                case 0b100100:
                    _and();
                    break;
                case 0b011010:
                    _div();
                    break;
                case 0b011011:
                    _divu();
                    break;
                case 0b001001:
                    _jalr();
                    break;
                case 0b001000:
                    _jr();
                    break;
                case 0b010000:
                    _mfhi();
                    break;
                case 0b010010:
                    _mflo();
                    break;
                case 0b010001:
                    _mthi();
                    break;
                case 0b010011:
                    _mtlo();
                    break;
                case 0b011000:
                    _mult();
                    break;
                case 0b011001:
                    _multu();
                    break;
                case 0b100111:
                    _nor();
                    break;
                case 0b100101:
                    _or();
                    break;
                case 0b000000:
                    _sll();
                    break;
                case 0b000100:
                    _sllv();
                    break;
                case 0b101010:
                    _slt();
                    break;
                case 0b101011:
                    _sltu();
                    break;
                case 0b000011:
                    _sra();
                    break;
                case 0b000111:
                    _srav();
                    break;
                case 0b000010:
                    _srl();
                    break;
                case 0b000110:
                    _srlv();
                    break;
                case 0b100010:
                    _sub();
                    break;
                case 0b100011:
                    _subu();
                    break;
                case 0b001100:
                    _syscall();
                    break;
                case 0b100110:
                    _xor();
                    break;
                default:
                    break;
            }
            break;
        
        case I_TYPE:
            switch (opCode) {
                case 0b001000:
                    _addi();
                    break;
                case 0b001001:
                    _addiu();
                    break;
                case 0b001100:
                    _andi();
                    break;
                case 0b000100:
                    _beq();
                    break;
                case 0b000001:
                    if (rt == 0b00001) {
                        _bgez();
                    } else if (rt == 0b00000) {
                        _bltz();
                    }
                    break;
                case 0b000111:
                    _bgtz();
                    break;
                case 0b000110:
                    _blez();
                    break;
                case 0b000101:
                    _bne();
                    break;
                case 0b100000:
                    _lb();
                    break;
                case 0b100100:
                    _lbu();
                    break;
                case 0b100001:
                    _lh();
                    break;
                case 0b100101:
                    _lhu();
                    break;
                case 0b001111:
                    _lui();
                    break;
                case 0b100011:
                    _lw();
                    break;
                case 0b001101:
                    _ori();
                    break;
                case 0b101000:
                    _sb();
                    break;
                case 0b001010:
                    _slti();
                    break;
                case 0b001011:
                    _sltiu();
                    break;
                case 0b101001:
                    _sh();
                    break;
                case 0b101011:
                    _sw();
                    break;
                case 0b001110:
                    _xori();
                    break;
                case 0b100010:
                    _lwl();
                    break;
                case 0b100110:
                    _lwr();
                    break;
                case 0b101010:
                    _swl();
                    break;
                case 0b101110:
                    _swr();
                    break;
                default:
                    break;
            }
            break;
        
        case J_TYPE:
            switch (opCode) {
                case 0b000010:
                    _j();
                    break;
                case 0b000011:
                    _jal();
                    break;
                default:
                    break;
            }
            break;
        
        default:
            break;
    }
}

void Simulator::parseInst(std::string inst) {
    opCode = binStrToNum(inst.substr(0, 6));
    if (opCode == 0b000000) {
        instType = R_TYPE;
        rs = binStrToNum(inst.substr(6, 5));
        rt = binStrToNum(inst.substr(11, 5));
        rd = binStrToNum(inst.substr(16, 5));
        sa = binStrToNum(inst.substr(21, 5));
        funct = binStrToNum(inst.substr(26, 6));
        // std::cout << "R-type, rs: " << rs << ", rt: " << rt << ", rd: " << rd << ", sa: " << sa << ", funct: " << funct << std::endl;
    } else if (opCode == 0b000010 or opCode == 0b000011) {
        instType = J_TYPE;
        target = binStrToNum(inst.substr(6, 26));
        // std::cout << "J-type, target: " << target << std::endl;
    } else {
        instType = I_TYPE;
        rs = binStrToNum(inst.substr(6, 5));
        rt = binStrToNum(inst.substr(11, 5));
        imm = binStrToNum(inst.substr(16, 16));
        // std::cout << "I-type, rs: " << rs << ", rt: " << rt << ", imm: " << imm << std::endl;
    }
}

void Simulator::preprocess() {
    /* Initialize text segment */
    for (int i = 0; i < insts.size(); i++) {
        auto &inst = insts[i];
        /* Little endian */
        for (int j = 0; j < 4; j++) {
            mem[i * 4 + 3 - j] = binStrToNum(inst.substr(j * 8, 8));
        }
    }
    /* Initialize data segment */
    std::ifstream in;
    in.open(inputAsm, std::ios::in);
    if (! in) {
        /* read input file failed */
        std::cout << inputAsm << " does not exist." << std::endl;
        return;
    }
    
    int insCnt = 0;
    std::string str;
    const std::string dotDataStr = ".data";
    const std::string dotTextStr = ".text";
    while (getline(in, str)) {
        if (trim(str).substr(0, 5) == dotDataStr) {
            break;
        }
    }
    /* .data section begins */
    memUsed = 0;
    std::stringstream ss;
    while (getline(in, str)) {
        if (trim(str).substr(0, 5) == dotTextStr) {
            break;
        }
        std::string dataStr, dataType;
        dataStr = trimToIns(str);
        ss.clear();
        ss.str(dataStr);
        ss >> dataType;
        if (dataType == ASCII or dataType == ASCIIZ) {
            std::string ascStr;
            getline(ss, ascStr);
            ascStr = unescapeStr(trim(ascStr, '\"'));
            if (dataType == ASCIIZ) {
                ascStr += '\0';
            }
            for (int i = 0; i < ascStr.size(); i++) {
                mem[TEXT_SEG_SIZE + memUsed++] = ascStr[i];
            }

        } else if (dataType == BYTE or dataType == HALF or dataType == WORD) {
            std::vector<int> numList;
            int num;
            char ch; /* comma */
            while (ss >> num) {
                numList.push_back(num);
                ss >> ch;
            }
            for (int i = 0; i < numList.size(); i++) {
                byte *ptr = mem + TEXT_SEG_SIZE + memUsed;
                if (dataType == BYTE) {
                    *ptr = numList[i];
                    memUsed++;
                } else if (dataType == HALF) {
                    *ptr = numList[i] & 0xff;
                    *(ptr + 1) = (numList[i] >> 8) & 0xff;
                    memUsed += 2;
                } else if (dataType == WORD) {
                    *ptr = numList[i] & 0xff;
                    *(ptr + 1) = (numList[i] >> 8) & 0xff;
                    *(ptr + 2) = (numList[i] >> 16) & 0xff;
                    *(ptr + 3) = (numList[i] >> 24) & 0xff;
                    memUsed += 4;
                }
            }
        }
        /* aligned to 4 bytes */
        if (memUsed & 3) {
            memUsed = (memUsed + 4) & ~3;
        }
    }
    in.close();
    
    /* Initialize checkpoints */
    in.open(outputCheckPts);
    int checkpoint;
    while (in >> checkpoint) {
        checkpoints.insert(checkpoint);
    }
}

void Simulator::_add() {
    reg[rd] = (int)reg[rs] + (int)reg[rt];
}

void Simulator::_addu() {
    reg[rd] = reg[rs] + reg[rt];
}

void Simulator::_and() {
    reg[rd] = reg[rs] & reg[rt];
}

void Simulator::_div() {
    reg[_lo] = (int)reg[rs] / (int)reg[rt];
    reg[_hi] = (int)reg[rs] % (int)reg[rt];
}

void Simulator::_divu() {
    reg[_lo] = reg[rs] / reg[rt];
    reg[_hi] = reg[rs] % reg[rt]; 
}

void Simulator::_jalr() {
    reg[rd] = reg[_pc]; /* rd == _ra == 31 */
    reg[_pc] = reg[rs];
}

void Simulator::_jr() {
    reg[_pc] = reg[rs];
}

void Simulator::_mfhi() {
    reg[rd] = reg[_hi];
}

void Simulator::_mflo() {
    reg[rd] = reg[_lo];
}

void Simulator::_mthi() {
    reg[_hi] = reg[rs];
}

void Simulator::_mtlo() {
    reg[_lo] = reg[rs];
}

void Simulator::_mult() {
    long long rst = reg[rs] * 1LL * reg[rt];
    reg[_hi] = rst >> 32;
    reg[_lo] = rst & 0xffffffff;
}

void Simulator::_multu() {
    unsigned long long rst = reg[rs] * 1ULL * reg[rt];
    reg[_hi] = rst >> 32;
    reg[_lo] = rst & 0xffffffff;
}

void Simulator::_nor() {
    reg[rd] = ~(reg[rs] | reg[rt]);
}

void Simulator::_or() {
    reg[rd] = reg[rs] | reg[rt];
}

void Simulator::_sll() {
    reg[rd] = reg[rt] << sa;
}

void Simulator::_sllv() {
    reg[rd] = reg[rt] << reg[rs];
}

void Simulator::_slt() {
    reg[rd] = (int)reg[rs] < (int)reg[rt] ? 1 : 0;
}

void Simulator::_sltu() {
    reg[rd] = reg[rs] < reg[rt] ? 1 : 0;
}

void Simulator::_sra() {
    uint32 signBit = 0x80000000 & reg[rt];
    reg[rd] = reg[rt] >> sa;
    if (signBit) {
        for (int i = 0; i < 32 and i < sa; i++) {
            reg[rd] |= signBit >> i;
        }
    }
}

void Simulator::_srav() {
    uint32 signBit = 0x80000000 & reg[rt];
    reg[rd] = reg[rt] >> reg[rs];
    if (signBit) {
        for (int i = 0; i < 32 and i < reg[rs]; i++) {
            reg[rd] |= signBit >> i;
        }
    }
}

void Simulator::_srl() {
    reg[rd] = reg[rt] >> sa;
}

void Simulator::_srlv() {
    reg[rd] = reg[rt] >> reg[rs];
}

void Simulator::_sub() {
    reg[rd] = (int)reg[rs] - (int)reg[rt];
}

void Simulator::_subu() {
    reg[rd] = reg[rs] - reg[rt];
}

void Simulator::_syscall() {
    switch (reg[_v0]) {
        case 1:
            _print_int();
            break;
        case 4:
            _print_string();
            break;
        case 5:
            _read_int();
            break;
        case 8:
            _read_string();
            break;
        case 9:
            _sbrk();
            break;
        case 10:
            _exit();
            break;
        case 11:
            _print_char();
            break;
        case 12:
            _read_char();
            break;
        case 13:
            _open();
            break;
        case 14:
            _read();
            break;
        case 15:
            _write();
            break;
        case 16:
            _close();
            break;
        case 17:
            _exit2();
            break;
        default:
            break;
    }
}

void Simulator::_xor() {
    reg[rd] = reg[rs] ^ reg[rt];
}

void Simulator::_addi() {
    reg[rt] = (int)reg[rs] + (short)imm;
}

void Simulator::_addiu() {
    reg[rt] = reg[rs] + (unsigned short)imm;
}

void Simulator::_andi() {
    reg[rt] = reg[rs] & (imm & 0xffff);
}

void Simulator::_beq() {
    if (reg[rs] == reg[rt]) {
        reg[_pc] += (short)imm * 4;
    }
}

void Simulator::_bgez() {
    if ((int)reg[rs] >= 0) {
        reg[_pc] += (short)imm * 4;
    }
}

void Simulator::_bgtz() {
    if ((int)reg[rs] > 0) {
        reg[_pc] += (short)imm * 4;
    }
}

void Simulator::_blez() {
    if ((int)reg[rs] <= 0) {
        reg[_pc] += (short)imm * 4;
    }
}

void Simulator::_bltz() {
    if ((int)reg[rs] < 0) {
        reg[_pc] += (short)imm * 4;
    }
}

void Simulator::_bne() {
    if (reg[rs] != reg[rt]) {
        reg[_pc] += (short)imm * 4;
    }
}

void Simulator::_lb() {
    reg[rt] = (char)mem[reg[rs] + (short)imm - MEM_BIAS];
}

void Simulator::_lbu() {
    reg[rt] = mem[reg[rs] + (short)imm - MEM_BIAS];
}

void Simulator::_lh() {
    byte hi = mem[reg[rs] + (short)imm - MEM_BIAS + 1];
    byte lo = mem[reg[rs] + (short)imm - MEM_BIAS];
    reg[rt] = lo | (hi << 8);
    if (hi & 0x80) {
        reg[rt] |= 0xffff << 16;
    }
}

void Simulator::_lhu() {
    byte hi = mem[reg[rs] + (short)imm - MEM_BIAS + 1];
    byte lo = mem[reg[rs] + (short)imm - MEM_BIAS];
    reg[rt] = lo | (hi << 8);
}

void Simulator::_lui() {
    reg[rt] = imm << 16;
}

void Simulator::_lw() {
    byte *base = mem + reg[rs] + (short)imm - MEM_BIAS;
    reg[rt] = base[0] | (base[1] << 8) | (base[2] << 16) | (base[3] << 24);
}

void Simulator::_ori() {
    reg[rt] = reg[rs] | imm;
}

void Simulator::_sb() {
    mem[reg[rs] + (short)imm - MEM_BIAS] = reg[rt] & 0xff;
}

void Simulator::_slti() {
    reg[rt] = ((int)reg[rs] < (short)imm) ? 1 : 0;
}

void Simulator::_sltiu() {
    reg[rt] = (reg[rs] < (unsigned short)imm) ? 1 : 0;
}

void Simulator::_sh() {
    byte *base = mem + reg[rs] + (short)imm - MEM_BIAS;
    base[0] = reg[rt] & 0xff;
    base[1] = reg[rt] >> 8;
}

void Simulator::_sw() {
    byte *base = mem + reg[rs] + (short)imm - MEM_BIAS;
    base[0] = reg[rt] & 0xff;
    base[1] = (reg[rt] >> 8) & 0xff;
    base[2] = (reg[rt] >> 16) & 0xff;
    base[3] = (reg[rt] >> 24) & 0xff;
}

void Simulator::_xori() {
    reg[rt] = reg[rs] ^ (unsigned short)imm;
}

/* Little endian */
void Simulator::_lwl() {
    int idx = reg[rs] + (short)imm - MEM_BIAS;
    int lowerBound = idx & (~3);
    for (int i = idx, j = 24; i >= lowerBound; i--, j -= 8) {
        reg[rt] &= ~(0xff << j);
        reg[rt] |= mem[i] << j;
    }
}

void Simulator::_lwr() {
    int idx = reg[rs] + (short)imm - MEM_BIAS;
    int upperBound = (idx + 4) & (~3);
    for (int i = idx, j = 0; i < upperBound; i++, j += 8) {
        reg[rt] &= ~(0xff << j);
        reg[rt] |= mem[i] << j;
    }
}

void Simulator::_swl() {
    int idx = reg[rs] + (short)imm - MEM_BIAS;
    int lowerBound = idx & (~3);
    for (int i = idx, j = 24; i >= lowerBound; i--, j -= 8) {
        mem[i] = (reg[rt] >> j) & 0xff;
    }
}

void Simulator::_swr() {
    int idx = reg[rs] + (short)imm - MEM_BIAS;
    int upperBound = (idx + 4) & (~3);
    for (int i = idx, j = 0; i < upperBound; i++, j += 8) {
        mem[i] = (reg[rt] >> j) & 0xff;
    }
}

void Simulator::_j() {
    reg[_pc] &= 0xf0000000;
    reg[_pc] |= target << 2;
}

void Simulator::_jal() {
    reg[_ra] = reg[_pc];
    reg[_pc] &= 0xf0000000;
    reg[_pc] |= target << 2;
}

void Simulator::_print_int() {
    fout << (int)reg[_a0];
    fout.flush();
}

void Simulator::_print_string() {
    fout << mem + reg[_a0] - MEM_BIAS;
    fout.flush();
}

void Simulator::_read_int() {
    int rst = 0;
    fin >> rst;
    std::string str;
    getline(fin, str);
    reg[_v0] = rst;
}

void Simulator::_read_string() {
    std::string str;
    getline(fin, str);
    for (int i = 0; i < reg[_a1]; i++) {
        mem[reg[_a0] - MEM_BIAS + i] = str[i];
    }
}

void Simulator::_sbrk() {
    reg[_v0] = MEM_BIAS + memUsed + TEXT_SEG_SIZE;
    memUsed += reg[_a0];
}

void Simulator::_exit() {
    shouldReturn = true;
    returnValue = 0;
}

void Simulator::_print_char() {
    fout << (char)reg[_a0];
    fout.flush();
}

void Simulator::_read_char() {
    reg[_v0] = fin.get();
    std::string str;
    getline(fin, str);
}

void Simulator::_open() {
    reg[_a0] = open((const char *)mem + reg[_a0] - MEM_BIAS, reg[_a1], reg[_a2]);
}

void Simulator::_read() {
    reg[_a0] = read(reg[_a0], mem + reg[_a1] - MEM_BIAS, reg[_a2]);
}

void Simulator::_write() {
    reg[_a0] = write(reg[_a0], mem + reg[_a1] - MEM_BIAS, reg[_a2]);
}

void Simulator::_close() {
    close(reg[_a0]);
}

void Simulator::_exit2() {
    shouldReturn = true;
    returnValue = reg[_a0];
}

void Simulator::dumpReg(int instCount) {
    std::ofstream os("register_" + std::to_string(instCount) + ".bin", std::ios::binary);
    os.write((const char *)reg, (REG_CNT + 3) << 2);
    os.close();
}

void Simulator::dumpMem(int instCount) {
    std::ofstream os("memory_" + std::to_string(instCount) + ".bin", std::ios::binary);
    os.write((const char *)mem, MAX_MEM_SIZE);
    os.close();
}