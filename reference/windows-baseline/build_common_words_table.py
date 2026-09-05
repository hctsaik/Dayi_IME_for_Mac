# -*- coding: utf-8 -*-
"""Build the curated Dayi2 common-word dictionaries.

Edit common_words.dict.yaml by hand, then run:
    python build_common_words_table.py

The script creates:
  * common_words_import.dict.yaml -- actively imported by dayi2.dict.yaml
  * common_words_table.dict.yaml  -- an optional table-translator version
"""

from collections import OrderedDict
from pathlib import Path


DIR = Path(__file__).resolve().parent
DAYI2_DICT = DIR / "dayi2.dict.yaml"
COMMON_WORDS_IN = DIR / "common_words.dict.yaml"
COMMON_WORDS_IMPORT_OUT = DIR / "common_words_import.dict.yaml"
COMMON_WORDS_TABLE_OUT = DIR / "common_words_table.dict.yaml"
DEFAULT_VERSION = "2026.08.14"
DELIMITER = " "


def load_version(path):
    """Use the source dictionary version for both generated dictionaries."""
    with path.open("r", encoding="utf-8") as source:
        for line in source:
            if line.startswith("version:"):
                value = line.partition(":")[2].strip().strip('"')
                if value:
                    return value
            if line.strip() == "...":
                break
    return DEFAULT_VERSION


def load_char_to_code(path):
    """Return each Dayi2 character's first available code."""
    char_to_code = {}
    in_body = False
    with path.open("r", encoding="utf-8") as source:
        for line in source:
            line = line.rstrip("\r\n")
            if line.strip() == "...":
                in_body = True
                continue
            if not in_body or not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) >= 2:
                char, code = parts[0].strip(), parts[1].strip()
                if len(char) == 1 and char not in char_to_code:
                    char_to_code[char] = code
    return char_to_code


def word_to_code(word, char_to_code):
    codes = []
    for char in word:
        code = char_to_code.get(char)
        if code is None:
            return None
        codes.append(code)
    return DELIMITER.join(codes)


def load_entries(path, char_to_code):
    """Read text<TAB>weight source rows and retain the highest duplicate weight."""
    entries = OrderedDict()
    in_body = False
    with path.open("r", encoding="utf-8") as source:
        for line in source:
            line = line.rstrip("\r\n")
            if line.strip() == "...":
                in_body = True
                continue
            if not in_body or not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) < 2:
                continue
            word = parts[0].strip()
            if len(word) < 2:
                continue
            try:
                weight = int(parts[1].strip())
            except ValueError:
                weight = 1000
            code = word_to_code(word, char_to_code)
            if code is None:
                print(f"Skipped unmappable word: {word}")
                continue
            previous = entries.get(word)
            if previous is None or weight > previous[1]:
                entries[word] = (code, weight)

    return sorted(
        ((code, word, weight) for word, (code, weight) in entries.items()),
        key=lambda item: (-item[2], item[1]),
    )


def write_import(entries, version):
    header = f"""---
name: common_words_import
version: "{version}"
sort: by_weight
...
"""
    with COMMON_WORDS_IMPORT_OUT.open("w", encoding="utf-8", newline="\n") as output:
        output.write(header)
        for code, word, weight in entries:
            output.write(f"{word}\t{code}\t{weight}\n")


def write_table(entries, version):
    header = f"""---
name: common_words_table
version: "{version}"
sort: by_weight
columns:
  - code
  - text
  - weight
...
"""
    with COMMON_WORDS_TABLE_OUT.open("w", encoding="utf-8", newline="\n") as output:
        output.write(header)
        for code, word, weight in entries:
            output.write(f"{code}\t{word}\t{weight}\n")
            compact_code = code.replace(" ", "")
            if compact_code != code:
                output.write(f"{compact_code}\t{word}\t{weight}\n")


def main():
    char_to_code = load_char_to_code(DAYI2_DICT)
    entries = load_entries(COMMON_WORDS_IN, char_to_code)
    version = load_version(COMMON_WORDS_IN)
    write_import(entries, version)
    write_table(entries, version)
    print(f"Generated {len(entries)} curated entries.")
    print(f"Updated {COMMON_WORDS_IMPORT_OUT.name} and {COMMON_WORDS_TABLE_OUT.name}.")


if __name__ == "__main__":
    main()
