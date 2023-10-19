#include <iostream>
#include <bitset>
#include <string>
#include <set>
#include <fstream>
#include <vector>
#include <sstream>
#include <iostream>
#include <cstring>

typedef unsigned char byte;

using namespace std;

string removeComments(string s) {
    if (s.find('#') != string::npos) {
        s = s.substr(0, s.find('#'));
    }
    return s;
}

/// remove blank space, '\t', '\n', .etc of string
/// \param s input string
/// \return trimmed string
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

string _fetchCode(unsigned int pc = 1) {
    unsigned int _block[10];
    _block[0] = 1;
    _block[1] = 2;
    _block[2] = 3;
    _block[3] = 4;
    _block[4] = 5;

    string res = bitset<8>(_block[pc + 3]).to_string() +
                 bitset<8>(_block[pc + 2]).to_string() +
                 bitset<8>(_block[pc + 1]).to_string() +
                 bitset<8>(_block[pc]).to_string();
    return res;
}

class A {
public:
    unsigned int *reg;
    A() {
        this->reg = new unsigned int[3];
        this->reg[0] = 2147483668;
        this->reg[1] = 2147483627;
        this->reg[2] = (int) this->reg[0] + (int) this->reg[1];
        cout << this->reg[2] << endl;
    }
};

int main() {
    A x;
//    ifstream inA;
//    ifstream inB;
//    // data segment
//    inA.open("a.txt", ios::in);
//    if (inA.fail()) {
//        cout << "assembly codes file doesn't open successfully!" << endl;
//        exit(1);
//    }
//
//    bool flag = false;  // .data detection
//    int pos = 0;  // current block position
//    string data = ".data";
//    string text = ".text";
//    string line;
//    while (getline(inA, line)) {
//        line = removeComments(line);
//        line = trim(line);  /// need to be decide of #
//        if (line.empty()) {
//            continue;
//        }
//        if (line.substr(0, 5) == data) {
//            flag = true;
//            continue;
//        }
//        if (line.substr(0, 5) == text) {
//            flag = false;
//            continue;
//        }
//        if (flag) {
//            if (line.find(':') != string::npos) {
//                if ((line.find('\"') == string::npos) || (line.find(':') < (line.find('\"')))) {
//                    line = line.substr(line.find(':') + 1);
//                }
//            }
//            line = trim(line);
//            if (line.empty()) {
//                continue;
//            }
//            string t = line.substr(0, line.find_first_of(" \t"));
//            cout << "\\" << t << "\\" << endl;
//            string d = line.substr(line.find_first_of(" \t"));
//            d = trim(d.substr(data.find_first_not_of(" \t")));  /// need to be decide of #
//            cout << "\\" << d << "\\" << endl;
//
//        }
//    }
//    inA.close();
//
//
//    string k = "123, 1234  ,  324\n";
//    int t = 1;
//
//    vector<int> l;
//    stringstream strStream;
//    strStream.str(k);
//    int num;
//    char comma;
//    while (strStream >> num) {
//        l.push_back(num);
//        strStream >> comma;
//    }
//    cout << l.size() << endl;
//    for(int i:l) {
//        cout << i << endl;
//    }
}
