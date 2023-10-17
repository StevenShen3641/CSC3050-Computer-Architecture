#include "LabelTable.h"
#include "util.h"
#include <fstream>
#include <iostream>
#include <sstream>

void LabelTable::pass1(std::string filename) {
    std::ifstream inFile;
    inFile.open(filename, std::ios::in);
    
    if (! inFile) {
        /* read input file failed */
        std::cout << filename << " does not exist." << std::endl;
        return;
    }

    insCnt = 0;
    std::string str;
    const std::string dotTextStr = ".text";
    while (getline(inFile, str)) {
        if (trim(str).substr(0, 5) == dotTextStr) {
            break;
        }
    }
    /* .text section begins */
    /* assuming that the input is valid, find all label */
    std::stringstream ss;
    std::string label;
    while (getline(inFile, str)) {
        ss.clear();
        ss.str(str);
        ss >> label;
        if (label.back() == ':') {
            labelMap[label.substr(0, label.length() - 1)] = insCnt;
        }
        
        if (trimToIns(str).length()) {
            insCnt++;
        }
    }
    inFile.close();
}