#ifndef LABEL_TABLE_H
#define LABEL_TABLE_H

#include <vector>
#include <string>
#include <map>
#include <sstream>

typedef unsigned int uint32;

enum INST_TYPE { R_TYPE, I_TYPE, J_TYPE };

enum ARG_TYPE { RS, RT, RD, SA, IMM, LABEL, IMM_RS, NO_ARG };

struct InstTable {
    std::string instName;
    INST_TYPE instType;
    uint32 opCode;
    uint32 functCode;
    ARG_TYPE argList[3];
};

#define REG_CNT 32

extern std::string regList[REG_CNT];

#define INST_TYPE_CNT 55

extern InstTable instTable[INST_TYPE_CNT];

class LabelTable
{
public:
    LabelTable() {
        for (int i = 0; i < INST_TYPE_CNT; i++) {
            instMap[instTable[i].instName] = instTable + i;
        }
        for (int i = 0; i < REG_CNT; i++) {
            regMap[regList[i]] = i;
        }
    }
    void pass1(std::string filename);
    void pass2(std::string filename, std::string outputFileName = "a.txt");
    void pass2(std::string filename, std::stringstream &ss);

private:
    int insCnt = 0;
    
    std::map<std::string, uint32> labelMap;
    std::map<std::string, InstTable*> instMap;
    std::map<std::string, int> regMap;

    std::string parse(std::string);

    std::string parseR(std::string instName, std::vector<std::string> argList);
    std::string parseI(std::string instName, std::vector<std::string> argList);
    std::string parseJ(std::string instName, std::vector<std::string> argList);
};

#endif