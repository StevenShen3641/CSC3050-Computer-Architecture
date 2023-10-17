#include "LabelTable.h"
#include "util.h"
#include <fstream>
#include <sstream>
#include <vector>
#include <iostream>

std::string LabelTable::parse(std::string inst) {
    std::stringstream ss;
    std::string instName, arg;
    for (int i = 0; i < inst.length(); i++) {
        if (inst[i] == ',') {
            inst.insert(i + 1, " ");
            i++;
        }
    }
    ss.str(inst);
    ss >> instName;
    std::vector<std::string> argList;
    while (ss >> arg) {
        if (arg != ",") {
            if (arg.back() == ',') {
                arg = arg.substr(0, arg.length() - 1);
            }
            argList.push_back(arg);
        }
    }

    INST_TYPE instType = instMap[instName]->instType;

    switch (instType) {
        case R_TYPE:
            return parseR(instName, argList);
        case I_TYPE:
            return parseI(instName, argList);
        case J_TYPE:
            return parseJ(instName, argList);
    }
    return "";
}

unsigned short parseNum(std::string str) {
    int num;
    unsigned short rst;
    std::stringstream ss;
    ss.str(str);
    ss >> num;
    rst = (unsigned short)num;
    return rst;
}

std::string LabelTable::parseR(std::string instName, std::vector<std::string> argList) {
    std::string opCode = "000000",
                rs = "00000",
                rt = "00000",
                rd = "00000",
                sa = "00000",
                function = "000000";
    InstTable *instInfo = instMap[instName];
    function = numToBinStr(instInfo->functCode, 6);
    for (int i = 0; i < argList.size(); i++) {
        switch (instInfo->argList[i]) {
        case RD:
            rd = numToBinStr(regMap[argList[i]], 5);
            break;
        case RS:
            rs = numToBinStr(regMap[argList[i]], 5);
            break;
        case RT:
            rt = numToBinStr(regMap[argList[i]], 5);
            break;
        case SA:
            sa = numToBinStr(parseNum(argList[i]), 5);
            break;
        }
    }
    return opCode + rs + rt + rd + sa + function;
}

std::string LabelTable::parseI(std::string instName, std::vector<std::string> argList) {
    std::string opCode = "000000",
                rs = "00000",
                rt = "00000",
                imm = "0000000000000000";
    if (instName == "bgez") {
        rt = "00001";
    }
    InstTable *instInfo = instMap[instName];
    opCode = numToBinStr(instInfo->opCode, 6);

    int leftB, rightB;
    for (int i = 0; i < argList.size(); i++) {
        switch (instInfo->argList[i]) {
        case RS:
            rs = numToBinStr(regMap[argList[i]], 5);
            break;
        case RT:
            rt = numToBinStr(regMap[argList[i]], 5);
            break;
        case IMM:
            imm = numToBinStr(parseNum(argList[i]), 16);
            break;
        case LABEL:
            imm = numToBinStr(labelMap[argList[i]] - insCnt - 1, 16);
            break;
        case IMM_RS:
            leftB = argList[i].find('(');
            rightB = argList[i].find(')');
            imm = numToBinStr(parseNum(argList[i].substr(0, leftB)), 16);
            rs = numToBinStr(regMap[argList[i].substr(leftB + 1, rightB - leftB - 1)], 5);
            break;
        }
    }
    return opCode + rs + rt + imm;
}

std::string LabelTable::parseJ(std::string instName, std::vector<std::string> argList) {
    std::string opCode = "000000",
                imm = "00000000000000000000000000";
    InstTable *instInfo = instMap[instName];
    opCode = numToBinStr(instInfo->opCode, 6);
    imm = numToBinStr(0x100000 + labelMap[argList[0]], 26);
    return opCode + imm;
}

void LabelTable::pass2(std::string filename, std::string outputFilename) {
    std::ifstream inFile;
    std::ofstream outFile;
    inFile.open(filename, std::ios::in);
    outFile.open(outputFilename, std::ios::out);

    insCnt = 0;
    std::string str;
    const std::string dotTextStr = ".text";
    while (getline(inFile, str)) {
        if (trim(str).substr(0, 5) == dotTextStr) {
            break;
        }
    }
    /* .text section begins */

    while (getline(inFile, str)) {
        str = trimToIns(str);
        if (str.length()) {
            outFile << parse(str) << std::endl;
            insCnt++;
        }
    }
}

void LabelTable::pass2(std::string filename, std::stringstream &ss) {
    std::ifstream inFile;
    std::ofstream outFile;
    inFile.open(filename, std::ios::in);

    insCnt = 0;
    std::string str;
    const std::string dotTextStr = ".text";
    while (getline(inFile, str)) {
        if (trim(str).substr(0, 5) == dotTextStr) {
            break;
        }
    }
    /* .text section begins */

    while (getline(inFile, str)) {
        str = trimToIns(str);
        if (str.length()) {
            ss << parse(str) << std::endl;
            insCnt++;
        }
    }
}