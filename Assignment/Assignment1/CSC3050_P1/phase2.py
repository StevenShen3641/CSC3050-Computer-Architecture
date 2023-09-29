import os
import sys

from phase1 import label_detect
from labelTable import LabelSet

START_ADDR = 0x400000

REGS = ["$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3", "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6",
        "$t7", "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp",
        "$ra"]

INST_R = {
    "add": [0x00, 0x20, ["rd", "rs", "rt"]],
    "addu": [0x00, 0x21, ["rd", "rs", "rt"]],
    "and": [0x00, 0x24, ["rd", "rs", "rt"]],
    "div": [0x00, 0x1A, ["rs", "rt"]],
    "divu": [0x00, 0x1B, ["rs", "rt"]],
    "jalr": [0x00, 0x09, ["rd", "rs"]],
    "jr": [0x00, 0x08, ["rs"]],
    "mfhi": [0x00, 0x10, ["rd"]],
    "mflo": [0x00, 0x12, ["rd"]],
    "mthi": [0x00, 0x11, ["rs"]],
    "mtlo": [0x00, 0x13, ["rs"]],
    "mult": [0x00, 0x18, ["rs", "rt"]],
    "multu": [0x00, 0x19, ["rs", "rt"]],
    "nor": [0x00, 0x27, ["rd", "rs", "rt"]],
    "or": [0x00, 0x25, ["rd", "rs", "rt"]],
    "sll": [0x00, 0x00, ["rd", "rt", "sa"]],
    "sllv": [0x00, 0x04, ["rd", "rt", "rs"]],
    "slt": [0x00, 0x2A, ["rd", "rs", "rt"]],
    "sltu": [0x00, 0x2B, ["rd", "rs", "rt"]],
    "sra": [0x00, 0x03, ["rd", "rt", "sa"]],
    "srav": [0x00, 0x07, ["rd", "rt", "rs"]],
    "srl": [0x00, 0x02, ["rd", "rt", "sa"]],
    "srlv": [0x00, 0x06, ["rd", "rt", "rs"]],
    "sub": [0x00, 0x22, ["rd", "rs", "rt"]],
    "subu": [0x00, 0x23, ["rd", "rs", "rt"]],
    "syscall": [0x00, 0x0C, []],
    "xor": [0x00, 0x26, ["rd", "rs", "rt"]]
}

INST_I = {
    "addi": [0x08, ["rt", "rs", "im"]],
    "addiu": [0x09, ["rt", "rs", "im"]],
    "andi": [0x0C, ["rt", "rs", "im"]],
    "beq": [0x04, ["rs", "rt", "label"]],
    "bgez": [0x01, ["rs", "label"]],
    "bgtz": [0x07, ["rs", "label"]],
    "blez": [0x06, ["rs", "label"]],
    "bltz": [0x01, ["rs", "label"]],
    "bne": [0x05, ["rs", "rt", "label"]],
    "lb": [0x20, ["rt", "im_rs"]],
    "lbu": [0x24, ["rt", "im_rs"]],
    "lh": [0x21, ["rt", "im_rs"]],
    "lhu": [0x25, ["rt", "im_rs"]],
    "lui": [0x0F, ["rt", "im"]],
    "lw": [0x23, ["rt", "im_rs"]],
    "ori": [0x0D, ["rt", "rs", "im"]],
    "sb": [0x28, ["rt", "im_rs"]],
    "slti": [0x0A, ["rt", "rs", "im"]],
    "sltiu": [0x0B, ["rt", "rs", "im"]],
    "sh": [0x29, ["rt", "im_rs"]],
    "sw": [0x2B, ["rt", "im_rs"]],
    "xori": [0x0E, ["rt", "rs", "im"]],
    "lwl": [0x22, ["rt", "im_rs"]],
    "lwr": [0x26, ["rt", "im_rs"]],
    "swl": [0x2A, ["rt", "im_rs"]],
    "swr": [0x2E, ["rt", "im_rs"]]
}

INST_J = {
    "j": [0x02, ["label"]],
    "jal": [0x03, ["label"]]
}


class RType:
    def __init__(self, op: int, func: int):
        """
        RType
        :param op: opcode
        :param func: function code
        """
        self.op = op
        self.func = func
        self.fields = {
            "rs": "00000",
            "rt": "00000",
            "rd": "00000",
            "sa": "00000"
        }

    def set_field(self, field: tuple[str, str]):
        self.fields[field[0]] = field[1]
        return

    def print_code(self):
        code = "".join(f"{self.op:06b}") + self.fields["rs"] + self.fields["rt"] + self.fields["rd"] + \
               self.fields["sa"] + "".join(f"{self.func:06b}")
        return code


class IType:
    def __init__(self, op: int):
        """
        IType
        :param op: opcode
        """
        self.op = op
        self.fields = {
            "rs": "00000",
            "rt": "00000",
            "im": "0" * 16
        }

    def set_field(self, field: tuple[str, str]):
        self.fields[field[0]] = field[1]
        return

    def print_code(self):
        code = "".join(f"{self.op:06b}") + self.fields["rs"] + self.fields["rt"] + self.fields["im"]
        return code


class JType:
    def __init__(self, op: int):
        """
        JType
        :param op: opcode
        """
        self.op = op
        self.target = "0" * 26

    def set_label(self, target: str):
        self.target = target
        return

    def print_code(self):
        code = "".join(f"{self.op:06b}") + self.target
        return code


def main():
    inp = sys.argv[1]
    """
    need to be changed
    """
    out = sys.argv[2]
    outfile = open(out, "w")
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
        address = START_ADDR
        while True:
            line = str(f.readline(), "utf-8")
            # avoid situation that .data appears below .text
            if line.find(".data") != -1:
                break
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
        for c in codes:
            outfile.write(c)
            outfile.write("\n")

    else:
        return


def parse_code(line, labels, current_addr):
    """
    return machine code for given line
    :param line: each line in testfile
    :param labels: label set
    :param current_addr: PC
    :return: machine code
    """
    flag = False
    line = line.replace(",", "").replace("\n", "").replace("\r", "")
    # remove comment
    if line.find("#") != -1:
        line = line.split("#")[0]
    # remove target
    if line.find(":") != -1:
        line = line.split(":")[1]
    # for im(rs)
    if line.find("(") != -1:
        flag = True
        line = line.replace("(", " ").replace(")", "")
    words = line.split()
    while "" in words:
        words.remove("")
    if len(words) == 0:
        return
    func = words[0]
    paras = words[1:]
    # eliminate the effect of $0
    temp = ["$zero" if i == "$0" else i for i in paras]
    paras = temp
    if flag:
        im_rs = paras[-2:]
        paras = paras[:-2]
        paras.append(im_rs)

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

    # IType
    elif func in INST_I.keys():
        inst = IType(INST_I[func][0])
        fields = INST_I[func][1]
        packs = list(zip(fields, paras))
        for p in packs:
            if p[0] in ["rs", "rt"]:
                inst.set_field((p[0], "".join(f"{REGS.index(p[1]):05b}")))
            elif p[0] == "im":
                # no need to distinguish signed and unsigned
                inst.set_field((p[0], "".join(f"{int(p[1]) & 0xffff:016b}")))
            elif p[0] == "label":
                label = p[1]
                # elif TODO: if it's integer
                addr = labels.get_address(label)
                relative_addr = (addr - current_addr - 4) // 4
                inst.set_field(("im", "".join(f"{relative_addr & 0xffff:016b}")))
            else:  # "im_rs"
                data = p[1]
                inst.set_field(("im", "".join(f"{int(data[0]) & 0xffff:016b}")))
                inst.set_field(("rs", "".join(f"{REGS.index(data[1]):05b}")))
        # special case for "bgez"
        if func == "bgez":
            inst.set_field(("rt", "00001"))
        return inst.print_code()

    # JType
    elif func in INST_J.keys():
        inst = JType(INST_J[func][0])
        label = paras[0]
        if label in labels.get_labels():
            addr = labels.get_address(label)
            coded_addr = addr // 4
            inst.set_label("".join(f"{coded_addr:026b}"))
            return inst.print_code()
        # elif TODO: if it's integer
        else:
            return
    else:
        return


if __name__ == '__main__':
    main()
