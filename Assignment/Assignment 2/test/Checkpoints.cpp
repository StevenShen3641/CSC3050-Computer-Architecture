//
// Created by 17119 on 2023/10/20.
//

#include "Checkpoints.h"

Checkpoints::Checkpoints() = default;

Checkpoints::~Checkpoints() = default;

void Checkpoints::push(int i) {
    _points.push_back(i);
}

void Checkpoints::dump(int instCount, unsigned int *_regs, unsigned char *_block, int size) {
    if (count(_points.begin(), _points.end(), instCount)) {
        ofstream d;

        // dump register
        d.open("register_" + to_string(instCount) + ".bin", ios::binary);
        d.write((char *) _regs, 35 * 4);
        d.flush();
        d.close();
        // dump memory
        d.open("memory_" + to_string(instCount) + ".bin", ios::binary);
        d.write((char *) _block, size);
        d.flush();
        d.close();
    }
}
