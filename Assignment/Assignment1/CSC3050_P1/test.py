a = [1, 2, 3]
b = a[-2:]
a = a[:-2]
a.append(b)
print(a)