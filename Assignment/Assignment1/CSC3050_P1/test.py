a = -1
b = f"{a:03b}"
print("".join(f"{a & 0xffff:016b}"))
print(-0x1 & 0xffff)
print(2 ** 16 - 1 & 0xffff)
