#ifndef MY_UTIL_H
#define MY_UTIL_H
#include <string>

std::string trim(std::string str, char c = ' ');

std::string numToBinStr(unsigned int num, int bit);

unsigned int binStrToNum(std::string str);

std::string trimToIns(std::string str);

std::string unescapeStr(std::string str);

#endif