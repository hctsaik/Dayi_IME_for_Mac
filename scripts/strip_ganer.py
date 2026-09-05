from pathlib import Path

src = Path("/tmp/dayi2-user.txt")
dst = Path("/tmp/dayi2-user-fixed.txt")
removed = []
keep = []
for line in src.read_text(encoding="utf-8").splitlines():
    if "感兒" in line:
        removed.append(line)
        continue
    keep.append(line)
dst.write_text("\n".join(keep) + "\n", encoding="utf-8")
print("removed", len(removed))
for item in removed:
    print(repr(item))
print("kept", len(keep))
