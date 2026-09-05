import json
from pathlib import Path
p = Path("/Users/heather/.config/karabiner/karabiner.json")
d = json.loads(p.read_text(encoding="utf-8"))
rules = d["profiles"][0]["complex_modifications"]["rules"]
mans = rules[0]["manipulators"]
print("rules", len(rules), "manipulators", len(mans))
print("simple", d["profiles"][0].get("simple_modifications"))
keys = [m["from"]["key_code"] for m in mans]
print("from", keys)
