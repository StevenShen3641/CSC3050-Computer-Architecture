import os

START_ADDR = 0x400000


def label_detect(file):
    """
    detect label
    :param file: file address
    :return: A dict containing label-address pair
    """
    label_addresses = {}
    file.seek(0, 2)
    eof = file.tell()
    file.seek(0, 0)
    while True:
        line = file.readline()
        if line.find(".text") != -1:
            break
    address = START_ADDR
    while True:
        line = file.readline()
        line = line.replace("\n", "")
        if line.find("#") != -1:
            line = line.split("#")[0]
        # end of file
        if file.tell() >= eof:
            break
        if line.find(":") != -1:
            label = line.split(":")[0].replace(" ", "").replace("\t", "")
            label_addresses[label] = address
        # check whether address should be increased
        joined_line = line.replace(" ", "").replace("\t", "")
        if len(joined_line) != 0 and joined_line[-1] != ":":
            address += 1
    return label_addresses
