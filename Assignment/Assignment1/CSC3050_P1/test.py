a = -2 ** 15
b = f"{a:03b}"
print("".join(f"{a & 0xffff:016b}"))
