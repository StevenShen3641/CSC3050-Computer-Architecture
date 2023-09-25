if __name__ == '__main__':
    f = open("label.txt", "r")
    for l in f.readlines():
        l = l.replace("\n", "")
        l = l.replace(",", "")
        l = l.replace("immediate", "im")
        l = l.replace("im(rs)", "im_rs")
        words = l.split(" ")
        formatted = "\"{}\": [".format(words.pop(0))
        code = str()
        field = "["
        index = 0
        for i in words:
            if i[0] != "0" and i[0] != "1":
                field += "\"{}\", ".format(i)
                index += 1
            else:
                break
        index += 1
        for i in range(index, len(words)):
            if words[i][0] != "0" and words[i][0] != "1":
                break
            else:
                code += "{}, ".format(words[i])
        formatted = formatted + code + field
        if formatted[-2] == ",":
            formatted = formatted[:-2]
        print(formatted + "]],")
