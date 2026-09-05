from pathlib import Path
p = Path("/Users/heather/Library/Rime/common_words_table.dict.yaml")
b = p.read_bytes()
print("tabs", b.count(9), "size", len(b))
lines = b.splitlines()
print(repr(lines[9]))
print(repr(lines[10]))
# find 感覺
for line in lines:
    if "感覺".encode("utf-8") in line and b"hzwq" in line:
        print("HIT", repr(line))
        break
