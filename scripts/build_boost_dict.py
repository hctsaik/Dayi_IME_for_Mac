from pathlib import Path

src = Path(r"c:\code\claude\IME\Apple_Dayi\myDayi-Mac-Handoff\reference\windows-baseline\common_words_import.dict.yaml")
out = Path(r"c:\code\claude\IME\Apple_Dayi\myDayi-Mac-Handoff\squirrel-user\mydayi_boost.dict.yaml")
lines = [
    "---",
    "name: mydayi_boost",
    'version: "20260905"',
    "sort: by_weight",
    "...",
]
n = 0
for raw in src.read_text(encoding="utf-8").splitlines():
    if not raw or raw.startswith("#") or raw.startswith("---") or raw.startswith("name:") or raw.startswith("version:") or raw.startswith("sort:") or raw == "...":
        continue
    parts = raw.split("\t")
    if len(parts) < 3:
        continue
    text, code, w = parts[0], parts[1], parts[2]
    compact = code.replace(" ", "")
    try:
        wi = int(w)
    except ValueError:
        continue
    lines.append(f"{text}\t{compact}\t{wi * 10000}")
    n += 1
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("entries", n, "bytes", out.stat().st_size)
