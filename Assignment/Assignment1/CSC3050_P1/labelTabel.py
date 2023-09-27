REGS = ["$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3", "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6",
        "$t7", "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp",
        "$ra"]

# FIELDS = ["null", "rd", "rs", "rt", "sa", "im", "target", "im(rs)"]

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
    def __init__(self, op: str, func: str):
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

    def set_field(self, field: tuple):
        self.fields[field[0]] = field[1]
        return

    def print_code(self):
        code = "".join(f"{self.op:06b}") + self.fields["rs"] + self.fields["rt"] + self.fields["rd"] + \
               self.fields["sa"] + "".join(f"{self.func:06b}")
        return code


class IType:
    def __init__(self, op: str):
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

    def set_field(self, field: tuple):
        self.fields[field[0]] = field[1]
        return

    def print_code(self):
        code = "".join(f"{self.op:06b}") + self.fields["rs"] + self.fields["rt"] + self.fields["im"]
        return code

class JType:
    def __init__(self, op: str):
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
