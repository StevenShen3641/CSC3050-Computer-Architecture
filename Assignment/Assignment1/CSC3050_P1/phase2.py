import sys
import os
from phase1 import label_detect
from labelTabel import REGS, INST_I, INST_J, INST_R, RType, IType, JType

START_ADDR = 0x400000


def main():
    inp = sys.argv[1]
    """
    need to be changed
    """
    # out = sys.argv[2]
    # outfile = open(out, "w")
    codes = []
    if os.path.exists(inp):
        f = open(inp, "rb")
        labels = label_detect(f)
        print(labels)
        f.seek(0, 2)
        eof = f.tell()
        f.seek(0, 0)
        while True:
            line = str(f.readline(), "utf-8")
            if line.find(".text") != -1:
                break
        address = START_ADDR
        while True:
            line = str(f.readline(), "utf-8")
            code = parse_code(line, labels, address)
            if code is None:
                if f.tell() >= eof:
                    break
                else:
                    continue
            codes.append(code)
            joined_line = line.replace(" ", "").replace("\t", "")
            if len(joined_line) != 0 and joined_line[-1] != ":":
                address += 4
        """
        need to be changed
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


def parse_code(line, labels, current_addr):
    line = line.replace(",", "").replace("\n", "").replace("\r", "")
    # remove comment
    if line.find("#") != -1:
        line = line.split("#")[0]
    # remove target
    if line.find(":") != -1:
        line = line.split(":")[1]
    words = line.split()
    while "" in words:
        words.remove("")
    if len(words) == 0:
        return
    func = words[0]
    paras = words[1:]

    # RType
    if func in INST_R.keys():
        inst = RType(INST_R[func][0], INST_R[func][1])
        fields = INST_R[func][2]
        for i in range(len(paras)):
            paras[i] = "".join(f"{REGS.index(paras[i]):05b}")
        packs = list(zip(fields, paras))
        for p in packs:
            inst.set_field(p)
        return inst.print_code()
    # TODO
    # IType
    elif func in INST_I.keys():
        inst = IType(INST_R[func][0])
        fields = INST_I[func][1]
        packs = list(zip(fields, paras))
        for p in packs:
            if p[0] in ["rs", "rt"]:
                inst.set_field((p[0], "".join(f"{REGS.index(p[1]):05b}")))
            elif p[0] is "im":
                inst.set_field((p[0], "".join(f"{p[1] & 0xffff:016b}")))
            elif p[0] is "label":
                pass
            else:  # "im_rs"
                pass

    # JType
    elif func in INST_J.keys():
        inst = JType(INST_J[func][0])
        label = paras[0]
        if label in labels.keys():
            addr = labels[label]
            coded_addr = addr // 4
            inst.set_label("".join(f"{coded_addr:026b}"))
            return inst.print_code()
        else:
            return
    else:
        return


if __name__ == '__main__':
    main()
