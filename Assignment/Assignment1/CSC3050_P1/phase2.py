import sys
import os
from phase1 import label_detect
from labelTabel import REGS, INST_I, INST_J, INST_R, RType, IType

START_ADDR = 0x400000


def main():
    inp = sys.argv[1]
    # out = sys.argv[2]
    # outfile = open(out, "w")
    codes = []
    if os.path.exists(inp):
        f = open(inp, "rb")
        labels = label_detect(f)
        f.seek(0, 2)
        eof = f.tell()
        f.seek(0, 0)
        while True:
            line = str(f.readline(), "utf-8")
            if line.find(".text") != -1:
                break
        while True:
            line = str(f.readline(), "utf-8")
            code = parse_code(line)
            if code is None:
                if f.tell() >= eof:
                    break
                else:
                    continue
            codes.append(code)
        """
        need to be change
        """
        flag = False
        for c in codes:
            if flag:
                # outfile.write("\n")
                print("")
            # outfile.write(c)
            print(c, end="")
            flag = True

    else:
        return


def parse_code(line):
    line = line.replace(",", "").replace("\n", "").replace("\r", "")
    # remove comment
    if line.find("#") != -1:
        line = line.split("#")[0]
    # remove label
    if line.find(":") != -1:
        line = line.split(":")[1]
    words = line.split()
    while "" in words:
        words.remove("")
    if len(words) == 0:
        return
    func = words[0]
    paras = words[1:]
    ### TODO
    # Rtype
    if func in INST_R.keys():
        inst = RType(INST_R[func][0], INST_R[func][1])
        fields = INST_R[func][2]
        for i in range(len(paras)):
            paras[i] = "".join(f"{REGS.index(paras[i]):05b}")
        packs = list(zip(fields, paras))
        for p in packs:
            inst.set_field(p)
        return inst.print_code()

    # Itype
    elif func in INST_I.keys():
        pass

    # Jtype
    elif func in INST_J.keys():
        pass
    else:
        return
    ###


if __name__ == '__main__':
    main()
