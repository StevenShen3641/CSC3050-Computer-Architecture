#include "simulator.h"
#include <iostream>

int main(int argc,char *argv[]) {
    if (argc != 6) {
        std::cout << "Please input the name of asm file, binary codes file, checkpoints file, input file and output file in order." << std::endl;
        return 0;
    }
    Simulator s(argv[1], argv[2], argv[3], argv[4], argv[5]);
    return s.run();
}