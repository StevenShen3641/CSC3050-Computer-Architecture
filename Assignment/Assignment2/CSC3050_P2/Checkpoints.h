//
// Created by 17119 on 2023/10/20.
//

#ifndef CSC3050_P2_CHECKPOINTS_H
#define CSC3050_P2_CHECKPOINTS_H

#include <string>
#include <fstream>
#include <vector>
#include <algorithm>

using namespace std;


class Checkpoints {
private:
    vector<int> _points;
public:
    Checkpoints();
    ~Checkpoints();
    void push(int i);
    void dump(int instCount, unsigned int *_regs, unsigned char *_block, int size);
};


#endif //CSC3050_P2_CHECKPOINTS_H
