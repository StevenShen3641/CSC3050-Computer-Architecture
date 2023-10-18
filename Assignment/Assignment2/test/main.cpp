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

vector<string> typeDataSplit(string s) {
    vector<string> res;
    int pos = 0;
    string type;
    string data;
    pos = s.find_first_of(" \t");
    type = s.substr(0, pos);
    data = s.substr(pos);
    data = data.substr(data.find_first_not_of(" \t"));
    res.push_back(type);
    res.push_back(data);
    return res;
}

int main() {
    string a = ".sadf\t    \tasdfasfsa";
    vector<string> x = typeDataSplit(a);
    for (string s:x) {
        cout << "\"" << s << "\"" << endl;
    }

}
