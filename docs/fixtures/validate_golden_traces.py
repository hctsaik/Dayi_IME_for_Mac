#!/usr/bin/env python3
"""Portable structural check for golden-traces.json. Does not run the IME."""
from __future__ import annotations

import json
import sys
from pathlib import Path

REQUIRED_GATES = {"frontend", "lexicon", "ranking"}
MIN_TRACES = 30

def main() -> int:
    path = Path(__file__).with_name("golden-traces.json")
    data = json.loads(path.read_text(encoding="utf-8"))
    traces = data["traces"]
    ids = [t["id"] for t in traces]
    errors: list[str] = []
    if len(traces) < MIN_TRACES:
        errors.append(f"need >= {MIN_TRACES} traces, got {len(traces)}")
    if len(ids) != len(set(ids)):
        errors.append("duplicate ids")
    for t in traces:
        if t.get("gate") not in REQUIRED_GATES:
            errors.append(f"{t.get('id')}: bad gate {t.get('gate')}")
        if "expect" not in t:
            errors.append(f"{t.get('id')}: missing expect")
    frontend = sum(1 for t in traces if t["gate"] == "frontend")
    lexicon = sum(1 for t in traces if t["gate"] == "lexicon")
    if frontend < 20:
        errors.append(f"too few frontend traces: {frontend}")
    if lexicon < 6:
        errors.append(f"too few lexicon traces: {lexicon}")
    if errors:
        print("FAIL")
        for e in errors:
            print(e)
        return 1
    print(f"PASS traces={len(traces)} frontend={frontend} lexicon={lexicon}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
