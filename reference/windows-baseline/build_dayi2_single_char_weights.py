#!/usr/bin/env python3
"""Build a Taiwan-frequency-ranked Dayi2 single-character table.

The canonical unweighted table is kept as dayi2_base.dict.yaml. This tool
copies every line to dayi2.dict.yaml and adds a third-column weight only to
one-Han-character rows. It never reads or changes any *.userdb
personal-learning database or the 40,000-entry common-phrase dictionary.

Frequency profile, in order of influence:
  * Academia Sinica Taiwan balanced corpus (primary)
  * TBCL written/spoken learner corpus (secondary)
  * Ministry of Education 85-year word-frequency survey (fallback)
  * Rime Essay (small coverage/tie contribution only)

Each corpus row contributes its frequency to every Han character it contains;
this measures character occurrence frequency rather than only standalone
single-character dictionary entries.

The source files are local research inputs and are not runtime dependencies.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from collections import defaultdict
from dataclasses import dataclass
from datetime import date
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parent
SCORE_SCALE = 10_000
SOURCE_WEIGHTS = {
    "sinica": 0.75,
    "tbcl": 0.15,
    "moe": 0.10,
    "essay": 0.05,
}


@dataclass
class CharacterRow:
    line_index: int
    character: str
    code: str
    fields: list[str]
    score: float = 0.0
    weight: int = 0


def is_han_character(text: str) -> bool:
    return len(text) == 1 and "\u3400" <= text <= "\u9fff"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require_file(path: Path) -> None:
    if not path.is_file():
        raise SystemExit(f"Missing required source: {path}")


def add_frequency(target: dict[str, int], text: str, value: int) -> None:
    """Accumulate character occurrences represented by a corpus word row."""
    if value <= 0:
        return
    for character in text:
        if is_han_character(character):
            target[character] = target.get(character, 0) + value


def parse_integer(value: object) -> int:
    try:
        return int(str(value).strip())
    except (TypeError, ValueError):
        return 0


def load_sinica(path: Path) -> dict[str, int]:
    result: dict[str, int] = {}
    for row in json.loads(path.read_text(encoding="utf-8")):
        add_frequency(result, str(row.get("word", "")).strip(), parse_integer(row.get("frequency")))
    return result


def load_tbcl(path: Path) -> dict[str, int]:
    result: dict[str, int] = {}
    with path.open("r", encoding="utf-8-sig", newline="") as source:
        for row in csv.DictReader(source):
            character = (row.get("Traditional") or "").strip()
            frequency = parse_integer(row.get("WFreq")) + parse_integer(row.get("SFreq"))
            add_frequency(result, character, frequency)
    return result


def load_moe(path: Path) -> dict[str, int]:
    result: dict[str, int] = {}
    # Government CSV is CP950/Big5-family data with a few invalid legacy bytes.
    with path.open("r", encoding="cp950", errors="replace", newline="") as source:
        rows = csv.reader(source)
        next(rows, None)
        for row in rows:
            if len(row) >= 3:
                add_frequency(result, row[1].strip(), parse_integer(row[2]))
    return result


def load_essay(path: Path) -> dict[str, int]:
    result: dict[str, int] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        try:
            character, raw_frequency = line.rsplit("\t", 1)
        except ValueError:
            continue
        add_frequency(result, character.strip(), parse_integer(raw_frequency))
    return result


def normalized_log(value: int, maximum: int) -> float:
    if value <= 0 or maximum <= 0:
        return 0.0
    return math.log1p(value) / math.log1p(maximum)


def load_base_rows(path: Path) -> tuple[list[str], str, bool, list[CharacterRow]]:
    raw = path.read_bytes()
    newline = "\r\n" if b"\r\n" in raw else "\n"
    text = raw.decode("utf-8")
    had_final_newline = text.endswith(("\r\n", "\n"))
    lines = text.splitlines()
    in_body = False
    rows: list[CharacterRow] = []
    for index, line in enumerate(lines):
        if line.strip() == "...":
            in_body = True
            continue
        if not in_body or not line or line.startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) >= 2 and is_han_character(fields[0]):
            rows.append(CharacterRow(index, fields[0], fields[1], fields))
    return lines, newline, had_final_newline, rows


def calculate_weights(
    rows: list[CharacterRow],
    sources: dict[str, dict[str, int]],
) -> tuple[int, dict[str, int]]:
    maxima = {name: max(values.values(), default=0) for name, values in sources.items()}
    by_code: dict[str, list[CharacterRow]] = defaultdict(list)
    for row in rows:
        row.score = sum(
            SOURCE_WEIGHTS[name]
            * normalized_log(values.get(row.character, 0), maxima[name])
            for name, values in sources.items()
        )
        by_code[row.code].append(row)

    max_candidates = max(
        (len({row.character for row in group}) for group in by_code.values()),
        default=1,
    )
    tie_scale = 10 ** len(str(max_candidates + 1))

    for group in by_code.values():
        unique_rows: list[CharacterRow] = []
        seen_characters: set[str] = set()
        for row in group:
            if row.character not in seen_characters:
                unique_rows.append(row)
                seen_characters.add(row.character)
        tie_bonus = {
            row.character: len(unique_rows) - position
            for position, row in enumerate(unique_rows)
        }
        for row in group:
            score_weight = round(row.score * SCORE_SCALE)
            row.weight = max(1, score_weight * tie_scale + tie_bonus[row.character])

    return tie_scale, maxima


def write_output(
    output: Path,
    lines: list[str],
    newline: str,
    had_final_newline: bool,
    rows: list[CharacterRow],
) -> None:
    replacements = {row.line_index: row for row in rows}
    rendered: list[str] = []
    for index, line in enumerate(lines):
        row = replacements.get(index)
        if row is None:
            rendered.append(line)
            continue
        fields = row.fields[:]
        if len(fields) >= 3:
            fields[2] = str(row.weight)
        else:
            fields.append(str(row.weight))
        rendered.append("\t".join(fields))
    text = newline.join(rendered)
    if had_final_newline:
        text += newline
    temporary = output.with_suffix(output.suffix + ".tmp")
    temporary.write_text(text, encoding="utf-8", newline="")
    temporary.replace(output)


def write_profile(
    profile: Path,
    rows: list[CharacterRow],
    sources: dict[str, dict[str, int]],
) -> None:
    unique: dict[tuple[str, str], CharacterRow] = {}
    for row in rows:
        unique.setdefault((row.character, row.code), row)
    lines = ["# character\tcode\tweight\tscore\tsinica\ttbcl\tmoe\tessay"]
    for character, code in sorted(unique, key=lambda item: (item[1], item[0])):
        row = unique[(character, code)]
        lines.append(
            "\t".join(
                [
                    character,
                    code,
                    str(row.weight),
                    f"{row.score:.8f}",
                    str(sources["sinica"].get(character, 0)),
                    str(sources["tbcl"].get(character, 0)),
                    str(sources["moe"].get(character, 0)),
                    str(sources["essay"].get(character, 0)),
                ]
            )
        )
    profile.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="")


def write_report(
    report: Path,
    base: Path,
    output: Path,
    profile: Path,
    sources: dict[str, dict[str, int]],
    source_paths: dict[str, Path],
    rows: list[CharacterRow],
    tie_scale: int,
) -> None:
    unique_characters = {row.character for row in rows}
    covered = {
        name: len(unique_characters & set(values))
        for name, values in sources.items()
    }
    by_code: dict[str, list[CharacterRow]] = defaultdict(list)
    for row in rows:
        by_code[row.code].append(row)

    def candidates(code: str, limit: int = 8) -> str:
        first_by_character: dict[str, CharacterRow] = {}
        for row in by_code[code]:
            first_by_character.setdefault(row.character, row)
        ranked = sorted(first_by_character.values(), key=lambda row: (-row.weight, row.line_index))
        return "、".join(row.character for row in ranked[:limit])

    lines = [
        "# Dayi2 單字常用度排序",
        "",
        f"產生日期：{date.today():%Y-%m-%d}",
        "",
        "此檔僅為 Dayi2 主碼表的一字漢字加入頻率權重；所有字碼與多字項目均保留。",
        "不讀取、不修改 common_words.userdb，也不變更 common_words_import.dict.yaml。",
        "",
        "## 權重來源",
        "",
        "| 來源 | 比重 | 覆蓋的 Dayi2 單字 | SHA-256 |",
        "| --- | ---: | ---: | --- |",
    ]
    for name in ("sinica", "tbcl", "moe", "essay"):
        lines.append(
            f"| {name} | {SOURCE_WEIGHTS[name]:.3f} | {covered[name]} | {sha256(source_paths[name])} |"
        )
    lines += [
        "",
        "Sinica 為主排序；TBCL、教育部詞頻補足；Essay 僅作弱的涵蓋／同分訊號。",
        "",
        "## 產物",
        "",
        f"- 基準表：{base.name}",
        f"- 加權主表：{output.name}",
        f"- 可稽核權重：{profile.name}",
        f"- 一字列：{len(rows):,}；不同字：{len(unique_characters):,}；同碼同分時保留基準表順序。",
        f"- 同分順序縮放值：{tie_scale}",
        "",
        "## 代表性結果",
        "",
        f"- oj：{candidates('oj')}",
        f"- sf：{candidates('sf')}",
        f"- ao：{candidates('ao')}",
        f"- ac：{candidates('ac')}",
        "",
    ]
    report.write_text("\n".join(lines), encoding="utf-8", newline="")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Directory containing Dayi2 tables.")
    parser.add_argument(
        "--source-root",
        type=Path,
        default=None,
        help="Directory containing lexicon_sources (defaults to --root).",
    )
    parser.add_argument("--base", type=Path, default=None, help="Unweighted canonical Dayi2 table.")
    parser.add_argument("--output", type=Path, default=None, help="Generated active Dayi2 table.")
    parser.add_argument("--profile", type=Path, default=None, help="Auditable per-character weight TSV.")
    parser.add_argument("--report", type=Path, default=None, help="Generated Markdown report.")
    parser.add_argument("--dry-run", action="store_true", help="Validate and report without writing files.")
    args = parser.parse_args()

    root = args.root.resolve()
    source_root = (args.source_root or root).resolve()
    base = (args.base or root / "dayi2_base.dict.yaml").resolve()
    output = (args.output or root / "dayi2.dict.yaml").resolve()
    profile = (args.profile or root / "dayi2_single_char_frequency.tsv").resolve()
    report = (args.report or root / "dayi2_single_char_rank_report.md").resolve()
    source_paths = {
        "sinica": source_root / "lexicon_sources" / "sinica_words.json",
        "tbcl": source_root / "lexicon_sources" / "tbcl.csv",
        "moe": source_root / "lexicon_sources" / "85rest02.csv",
        "essay": source_root / "lexicon_sources" / "essay.txt",
    }
    for path in (base, *source_paths.values()):
        require_file(path)

    sources = {
        "sinica": load_sinica(source_paths["sinica"]),
        "tbcl": load_tbcl(source_paths["tbcl"]),
        "moe": load_moe(source_paths["moe"]),
        "essay": load_essay(source_paths["essay"]),
    }
    lines, newline, had_final_newline, rows = load_base_rows(base)
    if not rows:
        raise SystemExit(f"No one-character Dayi2 rows found in: {base}")
    tie_scale, maxima = calculate_weights(rows, sources)

    by_code: dict[str, list[CharacterRow]] = defaultdict(list)
    for row in rows:
        by_code[row.code].append(row)
    oj = sorted(
        {row.character: row for row in by_code["oj"]}.values(),
        key=lambda row: (-row.weight, row.line_index),
    )
    print(
        f"Prepared {len(rows):,} one-character rows; "
        f"unique characters: {len({row.character for row in rows}):,}; "
        f"oj: {'、'.join(row.character for row in oj[:8])}"
    )
    print("Source maxima:", ", ".join(f"{name}={maxima[name]}" for name in sorted(maxima)))
    if args.dry_run:
        return

    output.parent.mkdir(parents=True, exist_ok=True)
    write_output(output, lines, newline, had_final_newline, rows)
    write_profile(profile, rows, sources)
    write_report(report, base, output, profile, sources, source_paths, rows, tie_scale)
    print(f"Wrote {output}")
    print(f"Wrote {profile}")
    print(f"Wrote {report}")


if __name__ == "__main__":
    main()
