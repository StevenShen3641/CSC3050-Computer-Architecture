#include "simulator.h"


int main(int argc, char *argv[]) {
    if (argc != 6) {
        cout << "Please input the six file names in order!" << endl;
        return 0;
    }
    string inAsm = argv[1];
    string inBin = argv[2];
    string checkPts = argv[3];
    string inFile = argv[4];
    string outFile = argv[5];

}
