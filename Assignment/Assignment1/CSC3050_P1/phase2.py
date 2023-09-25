import sys
import os
from phase1 import label_detect
from labelTabel import REGS, INST_I, INST_J, INST_R, RType, IType


# def

def main():
    inp = sys.argv[1]
    # out = sys.argv[2]
    # outfile = open(out, "w")
    if os.path.exists(inp):
        f = open(inp, "r")
        labels = label_detect(f)
        f.seek(0, 2)
        eof = f.tell()
        f.seek(0, 0)
        while True:
            line = f.readline()
            if line.find(".text") != -1:
                break
        while True:
            line = f.readline()
            code = parse_code(line)
            # outfile.write(code)
            if f.tell() >= eof:
                break
            # else:
            #     outfile.write("\n")
    else:
        return


def parse_code(line):
    line = line.replace(",", "").replace("\n", "")
    if line.find("#") != -1:
        line = line.split("#")[0]
    if line.find(":") != -1:
        line = line.split(":")[1]
    words = line.split(" ")
    ignore = ["", " "]
    for i in ignore:
        while i in words:
            words.remove(i)
    print(words)
    return


if __name__ == '__main__':
    main()
