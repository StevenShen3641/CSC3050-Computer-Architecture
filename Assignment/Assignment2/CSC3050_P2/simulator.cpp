//
// Created by 17119 on 2023/10/17.
//

#include "simulator.h"


Simulator::Simulator() : STACK_ADDR(0xA00000), START_ADDR(0x400000), STATIC_ADDR(0x500000), ASCII(".ascii"),
                         ASCIIZ(".asciiz"), Byte(".byte"), HALF(".half"), WORD(".word") {
    this->_regs = new unsigned int[35];
    this->_block = new unsigned char[STACK_ADDR - START_ADDR];

    // register initialization
    for (int i = 0; REG_NUM > i; i++) {
        _regs[i] = 0;
    }
    _regs[$zero] = 0;
    _regs[$pc] = START_ADDR;
    _regs[$fp] = _regs[$sp] = STACK_ADDR;
    _regs[$gp] = STATIC_ADDR + 0x8000;  // points to the middle of a 64K block in the static data segment

    // memory initialization
    memset(_block, 0, STACK_ADDR - START_ADDR);
}

Simulator::~Simulator() {
    delete[] _regs;
    delete[] _block;
}

void Simulator::init(const string &inAsm, const string &inBin) {
    ifstream inA;
    ifstream inB;
    // data segment
    inA.open(inAsm, ios::in);
    if (inA.fail()) {
        cout << "assembly codes file doesn't open successfully!" << endl;
        exit(1);
    }

    bool flag = false;  // .data detection
    int pos = 0;  // current block position
    string data = ".data";
    string text = ".text";
    string line;
    while (getline(inA, line)) {
        line = trim(line);
        if (line.empty()) {
            continue;
        }
        if (line.substr(0, 5) == data) {
            flag = true;
            continue;
        }
        if (line.substr(0, 5) == text) {
            flag = false;
            continue;
        }
        if (flag) {
            if (line.find(':') != string::npos) {
                line = line.substr(line.find_first_not_of(':'));
                vector<string> v = typeDataSplit(line);
                string t = v[0];
                string d = v[1];
                if (t == ASCII) {

                }
            } else {
                return;
            }

        }
    }




    // text segment
    inB.open(inBin, ios::in);
    if (inB.fail()) {
        cout << "binary codes file doesn't open successfully!" << endl;
        exit(1);
    }
    string inst;
    int count = 0;
    while (inB >> inst) {
        instructions.push_back(inst);
        for (int offset = 0; 4 > offset; offset++) {
            unsigned int bin = strToNum(inst.substr(offset * 8, 9));
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

unsigned int strToNum(const string &s) {
    unsigned int res = 0;
    for (char c: s) {
        res = (res << 1) | (c - '0');
    }
    return res;
}

string trim(string s) {
    if (s.empty()) {
        return s;
    }

    // remove blank part
    s = s.substr(s.find_first_not_of(" \t\n"));
    s = s.substr(0, s.find_last_not_of(" \t\n") + 1);

    // remove comments
    if (s.find('#') != string::npos) {
        s = s.substr(0, s.find('#'));
    }
    return s;
}

vector<string> typeDataSplit(const string& s) {
    vector<string> res;
    string type;
    string data;
    type = s.substr(0, s.find_first_of(" \t"));
    data = s.substr(s.find_first_of(" \t"));
    data = data.substr(data.find_first_not_of(" \t"));
    res.push_back(type);
    res.push_back(data);
    return res;
}

