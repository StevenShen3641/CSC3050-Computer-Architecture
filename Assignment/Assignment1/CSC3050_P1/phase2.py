from phase1 import label_detect
from labelTabel import REGS, INST_I, INST_J, INST_R, RType, IType

# def

if __name__ == '__main__':
    infile = "testfile3.asm"
    print(label_detect(infile))