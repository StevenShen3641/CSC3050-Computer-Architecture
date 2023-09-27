START_ADDR = 0x400000


def label_detect(file):
    """
    detect target
    :param file: file address
    :return: A dict containing target-address pair
    """
    label_addresses = {}
    file.seek(0, 2)
    eof = file.tell()
    file.seek(0, 0)
    # locate the start of the code
    while True:
        line = str(file.readline(), "utf-8")
        if line.find(".text") != -1:
            break
    address = START_ADDR
    # find labels
    while True:
        line = str(file.readline(), "utf-8")
        # avoid situation that .data appears below .text
        if line.find(".data") != -1:
            break
        line = line.replace("\n", "").replace("\r", "")
        # remove comment
        if line.find("#") != -1:
            line = line.split("#")[0]
        # get target
        if line.find(":") != -1:
            label = line.split(":")[0].replace(" ", "").replace("\t", "")
            label_addresses[label] = address
        # check whether address should be increased
        joined_line = line.replace(" ", "").replace("\t", "")
        if len(joined_line) != 0 and joined_line[-1] != ":":
            address += 4  # add a word
        # end of file
        if file.tell() >= eof:
            break
    return label_addresses
