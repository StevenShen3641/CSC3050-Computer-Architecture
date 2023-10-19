//
// Created by 17119 on 2023/10/17.
//

#include "simulator.h"


Simulator::Simulator() : STACK_ADDR(0xA00000), START_ADDR(0x400000), STATIC_ADDR(0x500000), ASCII(".ascii"),
                         ASCIIZ(".asciiz"), BYTE(".byte"), HALF(".half"), WORD(".word") {
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

    // current block position
    staticDataPos = 0;
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
    string data = ".data";
    string text = ".text";
    string line;
    while (getline(inA, line)) {
        line = removeComments(line);
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
                if ((line.find('\"') == string::npos) || (line.find(':') < (line.find('\"')))) {
                    line = line.substr(line.find(':') + 1);
                }
            }
            line = trim(line);
            if (line.empty()) {
                continue;
            }
            string t = line.substr(0, line.find_first_of(" \t"));
            string d = line.substr(line.find_first_of(" \t"));
            d = trim(d.substr(data.find_first_not_of(" \t")));
            if (t == ASCII || t == ASCIIZ) {
                d = escape(d.substr(1, d.size() - 2));
                (t == ASCIIZ) ? (d += '\0') : d;
                for (char c: d) {
                    this->_block[STATIC_ADDR - START_ADDR + staticDataPos++] = c;
                }

            } else {
                vector<int> l;
                stringstream strStream;
                strStream.str(d);
                int num;
                char comma;
                while (strStream >> num) {
                    l.push_back(num);
                    strStream >> comma;
                }
                if (t == BYTE) {
                    for (int i: l) {
                        this->_block[STATIC_ADDR - START_ADDR + staticDataPos++] = i;
                    }
                } else if (t == HALF) {
                    for (int i: l) {
                        for (int j = 0; j < 16; j += 8) {
                            this->_block[STATIC_ADDR - START_ADDR + staticDataPos++] = (i >> j) & 0xff;
                        }
                    }
                } else if (t == WORD) {
                    for (int i: l) {
                        for (int j = 0; j < 32; j += 8) {
                            this->_block[STATIC_ADDR - START_ADDR + staticDataPos++] = (i >> j) & 0xff;
                        }
                    }
                }


            }
            if (staticDataPos % 4 != 0) {
                staticDataPos = ((staticDataPos / 4) + 1) * 4;
            }

        }
    }
    inA.close();

    // text segment
    inB.open(inBin, ios::in);
    if (inB.fail()) {
        cout << "binary codes file doesn't open successfully!" << endl;
        exit(1);
    }
    string inst;
    int count = 0;
    while (inB >> inst) {
        for (int offset = 0; 4 > offset; offset++) {
            unsigned int bin = strToNum(inst.substr(offset * 8, 8));
            this->_block[4 * count + 3 - offset] = bin;
        }
        count++;
    }
    inB.close();
    /// checkpoint needed
}

void Simulator::simulate(const string &inFile, const string &outFile) {
    // read input and output file
    inF.open(inFile, ios::in);
    if (inF.fail()) {
        cout << "input file doesn't open successfully!" << endl;
        exit(1);
    }
    outF.open(outFile, ios::out);

    // start simulating
    string inst = _fetchCode(this->_regs[$pc]);





}

string Simulator::_fetchCode(unsigned int pc) {
    string res = bitset<8>(this->_block[pc - START_ADDR + 3]).to_string() +
                 bitset<8>(this->_block[pc - START_ADDR + 2]).to_string() +
                 bitset<8>(this->_block[pc - START_ADDR + 1]).to_string() +
                 bitset<8>(this->_block[pc - START_ADDR]).to_string();
    return res;
}

void Simulator::_rType(string rs, string rt, string rd, string sa, string func) {

};

void Simulator::_iType(string op, string rs, string rt, string imm) {

};

void Simulator::_jType(string op, string target) {

};

unsigned int strToNum(const string &s) {
    unsigned int res = 0;
    for (char c: s) {
        res = (res << 1) | (c - '0');
    }
    return res;
}

string removeComments(string s) {
    if (s.find('#') != string::npos) {
        s = s.substr(0, s.find('#'));
    }
    return s;
}

string trim(string s) {
    if (s.empty()) {
        return s;
    }

    // remove blank part
    if (s.find_first_not_of(" \t\n") == string::npos) {
        return "";
    }
    s = s.substr(s.find_first_not_of(" \t\n"));
    s = s.substr(0, s.find_last_not_of(" \t\n") + 1);

    return s;
}

string escape(string s) {
    string res;
    int pos = 0;
    while (s.size() > pos) {
        if (s[pos] == '\\' && s.size() > (pos + 1)) {
            char next = s[pos + 1];
            switch (next) {
                case 'a':
                    res += '\a';
                    break;
                case 'b':
                    res += '\b';
                    break;
                case 'f':
                    res += '\f';
                    break;
                case 'n':
                    res += '\n';
                    break;
                case 'r':
                    res += '\r';
                    break;
                case 't':
                    res += '\t';
                    break;
                case 'v':
                    res += '\v';
                    break;
                case '\\':
                    res += '\\';
                    break;
                case '\'':
                    res += '\'';
                    break;
                case '\"':
                    res += "\"";
                    break;
                case '\?':
                    res += '\?';
                    break;
                case '0':
                    res += '\0';
                    break;
                default:
                    res += '\\';
                    pos--;
            }
            pos += 2;
        } else {
            res += s[pos++];
        }
    }
    return res;
}
