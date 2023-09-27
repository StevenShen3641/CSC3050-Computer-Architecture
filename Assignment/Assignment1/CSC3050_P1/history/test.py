paras = ["$at", "$zero", "-13", "0", "$0"]

temp = ["$zero" if i == "$0" else i for i in paras]
paras = temp
print(paras)