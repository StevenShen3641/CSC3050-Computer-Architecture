//
// Created by 17119 on 2023/10/17.
//

#include "Simulator.h"


Simulator::Simulator() : STACK_ADDR(0xA00000), START_ADDR(0x400000), STATIC_ADDR(0x500000), ASCII(".ascii"),
                         ASCIIZ(".asciiz"), BYTE(".byte"), HALF(".half"), WORD(".word") {
    this->_regs = new unsigned int[35];
    this->_block = new unsigned char[STACK_ADDR - START_ADDR];

    // register initialization
    for (int i = 0; REG_NUM > i; i++) {
        this->_regs[i] = 0;
    }
    this->_regs[$zero] = 0;
    this->_regs[$pc] = START_ADDR;
    this->_regs[$fp] = this->_regs[$sp] = STACK_ADDR;
    this->_regs[$gp] = STATIC_ADDR + 0x8000;  // points to the middle of a 64K block in the static data segment

    // memory initialization
    memset(_block, 0, STACK_ADDR - START_ADDR);

    // current block position
    staticDataPos = 0;
}

Simulator::~Simulator() {
    delete[] this->_regs;
    delete[] this->_block;
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
    while (true) {


        /// checkpoints
        string inst = _fetchCode(this->_regs[$pc]);

    }


}

string Simulator::_fetchCode(unsigned int pc) {
    string res = bitset<8>(this->_block[pc - START_ADDR + 3]).to_string() +
                 bitset<8>(this->_block[pc - START_ADDR + 2]).to_string() +
                 bitset<8>(this->_block[pc - START_ADDR + 1]).to_string() +
                 bitset<8>(this->_block[pc - START_ADDR]).to_string();
    return res;
}

void Simulator::_execute(const string& inst) {
    unsigned int op = strToNum(inst.substr(0, 6));
    if (op == 0b000000) {
        _rType(strToNum(inst.substr(6, 5)), strToNum(inst.substr(11, 5)),
               strToNum(inst.substr(16, 5)), strToNum(inst.substr(21, 5)),
               strToNum(inst.substr(26, 6)));
    } else if (op == 0b000010 || op == 0b000011) {
        _jType(strToNum(inst.substr(0, 6)), strToNum(inst.substr(6, 26)));
    } else {
        _iType(strToNum(inst.substr(0, 6)), strToNum(inst.substr(6, 5)),
               strToNum(inst.substr(11, 5)), strToNum(inst.substr(16, 16)));
    }
}

void Simulator::_rType(unsigned int rs, unsigned int rt, unsigned int rd, unsigned int sa, unsigned int func) {
    switch (func) {
        case 0b100000:  // add
            this->_regs[rd] = (int) this->_regs[rs] + (int) this->_regs[rt];
            break;
        case 0b100001:  // addu
            this->_regs[rd] = this->_regs[rs] + this->_regs[rt];
            break;
        case 0b100100:  // and
            this->_regs[rd] = this->_regs[rs] & this->_regs[rd];
            break;
        case 0b011010:  // div
            this->_regs[$lo] = (int) this->_regs[rs] / (int) this->_regs[rt];
            this->_regs[$hi] = (int) this->_regs[rs] % (int) this->_regs[rt];
            break;
        case 0b011011:  // divu
            this->_regs[$lo] = this->_regs[rs] / this->_regs[rt];
            this->_regs[$hi] = this->_regs[rs] % this->_regs[rt];
            break;
        case 0b001001:  // jalr
            this->_regs[rd] = this->_regs[$pc];
            this->_regs[$pc] = this->_regs[rs];
            break;
        case 0b001000:  // jr
            this->_regs[$pc] = this->_regs[rs];
            break;
        case 0b010000:  // mfhi
            this->_regs[rd] = this->_regs[$hi];
            break;
        case 0b010010:  // mflo
            this->_regs[rd] = this->_regs[$lo];
            break;
        case 0b010001:  // mthi
            this->_regs[$hi] = this->_regs[rs];
            break;
        case 0b010011:  // mtlo
            this->_regs[$lo] = this->_regs[rs];
            break;
        case 0b011000:  // mult
            ll resMult;
            resMult = 1LL * (int) this->_regs[rs] * (int) this->_regs[rt];
            this->_regs[$lo] = resMult & 0xffffffff;
            this->_regs[$hi] = (resMult >> 32) & 0xffffffff;
            break;
        case 0b011001:  // multu
            ull resMultu;
            resMultu = 1ULL * this->_regs[rs] * this->_regs[rt];
            this->_regs[$lo] = resMultu & 0xffffffff;
            this->_regs[$hi] = (resMultu >> 32) & 0xffffffff;
            break;
        case 0b100111:  // nor
            this->_regs[rd] = ~(this->_regs[rs] | this->_regs[rt]);
            break;
        case 0b100101:  // or
            this->_regs[rd] = this->_regs[rs] | this->_regs[rt];
            break;
        case 0b000000:  // sll
            this->_regs[rd] = this->_regs[rt] << sa;
            break;
        case 0b000100:  // sllv
            this->_regs[rd] = this->_regs[rt] << this->_regs[rs];
            break;
        case 0b101010:  // slt
            this->_regs[rd] = (int) this->_regs[rs] < (int) this->_regs[rt] ? 1 : 0;
            break;
        case 0b101011:  // sltu
            this->_regs[rd] = this->_regs[rs] < this->_regs[rt] ? 1 : 0;
            break;
        case 0b000011:  // sra
            this->_regs[rd] = this->_regs[rt] >> sa;
            if (0x80000000 & this->_regs[rt]) {
                for (int i = 31; (31 - sa < i) && (0 <= i); i--) {
                    this->_regs[rd] |= (1 << i);
                }
            }
            break;
        case 0b000111:  // srav
            this->_regs[rd] = this->_regs[rt] >> this->_regs[rs];
            if (0x80000000 & this->_regs[rt]) {
                for (int i = 31; (31 - this->_regs[rs] < i) && (0 <= i); i--) {
                    this->_regs[rd] |= (1 << i);
                }
            }
            break;
        case 0b000010:  // srl
            this->_regs[rd] = this->_regs[rt] >> sa;
            break;
        case 0b000110:  // srlv
            this->_regs[rd] = this->_regs[rt] >> this->_regs[rs];
            break;
        case 0b100010:  // sub
            this->_regs[rd] = (int) this->_regs[rs] - (int) this->_regs[rt];
            break;
        case 0b100011:  // subu
            this->_regs[rd] = this->_regs[rs] - this->_regs[rt];
            break;
        case 0b001100:
            _syscall();
            break;
        case 0b100110:  // xor
            this->_regs[rd] = this->_regs[rs] ^ this->_regs[rt];
        default:
            break;
    }
}

void Simulator::_syscall() {
    switch (this->_regs[$v0]) {
        case 1:  // print_int
            outF << (int) this->_regs[$a0];

            break;
        case 4:
            //_print_string();
            break;
        case 5:
            //_read_int();
            break;
        case 8:
            //_read_string();
            break;
        case 9:
            //_sbrk();
            break;
        case 10:
            //_exit();
            break;
        case 11:
            //_print_char();
            break;
        case 12:
            //_read_char();
            break;
        case 13:
            //_open();
            break;
        case 14:
            //_read();
            break;
        case 15:
            //_write();
            break;
        case 16:
            //_close();
            break;
        case 17:
            //_exit2();
            break;
        default:
            break;
    }
}

void Simulator::_iType(unsigned int op, unsigned int rs, unsigned int rt, unsigned int imm) {

}

void Simulator::_jType(unsigned int op, unsigned int target) {

}

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
