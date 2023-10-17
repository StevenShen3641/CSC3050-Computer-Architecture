#include "util.h"
#include <iostream>

std::string trim(std::string s, char c) {
    if (s.empty()) {
        return s;  
    }

    s.erase(0, s.find_first_not_of(' '));
    s.erase(s.find_last_not_of(' ') + 1);
    s.erase(0, s.find_first_not_of('\t'));
    s.erase(s.find_last_not_of('\t') + 1);
    s.erase(0, s.find_first_not_of('\n'));
    s.erase(s.find_last_not_of('\n') + 1);
    if (c != ' ') {
        s.erase(0, s.find_first_not_of(c));  
        s.erase(s.find_last_not_of(c) + 1);
    }
    return s;
}

std::string numToBinStr(unsigned int num, int bit) {
    std::string zero = "0", one = "1", rst;
    while (num || bit) {
        if (num & 1) {
            rst = one + rst;
        } else {
            rst = zero + rst;
        }
        num >>= 1;
        bit--;
        if (bit == 0) {
            break;
        }
    }
    return rst;
}

std::string trimToIns(std::string str) {
    if (str.find_first_of('#') != str.npos) {
        str = str.substr(0, str.find_first_of('#'));
    }
    if (str.find(':') != str.npos) {
        str = str.substr(str.find(':') + 1, str.length());
    }
    return trim(str);
}

unsigned int binStrToNum(std::string str) {
    unsigned int rst = 0;
    for (char c : str) {
        rst <<= 1;
        rst |= c - '0';
    }
    return rst;
}

std::string unescapeStr(std::string str) {
    std::string rst;
    auto it = str.begin();
    while (it != str.end()) {
        char c = *it++;
        if (c == '\\' && it != str.end()) {
            switch (*it++) {
                case '\\': c = '\\'; break;
                case 'n': c = '\n'; break;
                case 't': c = '\t'; break;
                case '\'': c = '\''; break;
                case '\?': c = '\?'; break;
                case 'a': c = '\a'; break;
                case 'b': c = '\b'; break;
                case 'f': c = '\f'; break;
                case 'r': c = '\r'; break;
                case 'v': c = '\v'; break;
                default: continue;
            }
        }
        rst += c;
    }
    return rst;
}