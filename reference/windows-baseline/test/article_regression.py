"""Article-level Dayi 2 regression test.

The runner pins a Wikipedia revision, extracts readable paragraphs, derives
Dayi input cases from the active dictionary, and asks librime for the first
candidate without committing anything.  A temporary Rime user directory is
used so the live Weasel process and its user database are never modified.
"""

from __future__ import annotations

import argparse
import ctypes
import html
import json
import os
import re
import shutil
import sys
import tempfile
import urllib.parse
import urllib.request
from collections import Counter
from pathlib import Path


PINNED_REVISION = 93857310
PINNED_TIMESTAMP = "2026-08-12T01:01:32Z"
WIKIPEDIA_API = "https://zh.wikipedia.org/w/api.php"
WIKIPEDIA_TITLE = "臺灣"
WIKIPEDIA_PAGE_URL = "https://zh.wikipedia.org/wiki/%E8%87%BA%E7%81%A3"
WIKIMEDIA_LICENSE_URL = "https://foundation.wikimedia.org/wiki/Policy:Terms_of_Use"


class RimeTraits(ctypes.Structure):
    _fields_ = [
        ("data_size", ctypes.c_int),
        ("shared_data_dir", ctypes.c_char_p),
        ("user_data_dir", ctypes.c_char_p),
        ("distribution_name", ctypes.c_char_p),
        ("distribution_code_name", ctypes.c_char_p),
        ("distribution_version", ctypes.c_char_p),
        ("app_name", ctypes.c_char_p),
        ("modules", ctypes.POINTER(ctypes.c_char_p)),
        ("min_log_level", ctypes.c_int),
        ("log_dir", ctypes.c_char_p),
        ("prebuilt_data_dir", ctypes.c_char_p),
        ("staging_dir", ctypes.c_char_p),
    ]


class RimeComposition(ctypes.Structure):
    _fields_ = [
        ("length", ctypes.c_int),
        ("cursor_pos", ctypes.c_int),
        ("sel_start", ctypes.c_int),
        ("sel_end", ctypes.c_int),
        ("preedit", ctypes.c_char_p),
    ]


class RimeCandidate(ctypes.Structure):
    _fields_ = [
        ("text", ctypes.c_char_p),
        ("comment", ctypes.c_char_p),
        ("reserved", ctypes.c_void_p),
    ]


class RimeMenu(ctypes.Structure):
    _fields_ = [
        ("page_size", ctypes.c_int),
        ("page_no", ctypes.c_int),
        ("is_last_page", ctypes.c_int),
        ("highlighted_candidate_index", ctypes.c_int),
        ("num_candidates", ctypes.c_int),
        ("candidates", ctypes.POINTER(RimeCandidate)),
        ("select_keys", ctypes.c_char_p),
    ]


class RimeContext(ctypes.Structure):
    _fields_ = [
        ("data_size", ctypes.c_int),
        ("composition", RimeComposition),
        ("menu", RimeMenu),
        ("commit_text_preview", ctypes.c_char_p),
        ("select_labels", ctypes.POINTER(ctypes.c_char_p)),
    ]


class RimeCommit(ctypes.Structure):
    _fields_ = [("data_size", ctypes.c_int), ("text", ctypes.c_char_p)]


VoidFn = ctypes.CFUNCTYPE(None)
SetupFn = ctypes.CFUNCTYPE(None, ctypes.POINTER(RimeTraits))
NotifyFn = ctypes.CFUNCTYPE(
    None, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_char_p
)
InitializeFn = ctypes.CFUNCTYPE(None, ctypes.POINTER(RimeTraits))
MaintenanceFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_int)
CreateSessionFn = ctypes.CFUNCTYPE(ctypes.c_size_t)
FindSessionFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t)
DestroySessionFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t)
ProcessKeyFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.c_int, ctypes.c_int)
ClearCompositionFn = ctypes.CFUNCTYPE(None, ctypes.c_size_t)
CommitCompositionFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t)
GetCommitFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.POINTER(RimeCommit))
FreeCommitFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.POINTER(RimeCommit))
GetContextFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.POINTER(RimeContext))
FreeContextFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.POINTER(RimeContext))
SelectSchemaFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.c_char_p)


class RimeApi(ctypes.Structure):
    _fields_ = [
        ("data_size", ctypes.c_int),
        ("setup", SetupFn),
        ("set_notification_handler", ctypes.CFUNCTYPE(None, NotifyFn, ctypes.c_void_p)),
        ("initialize", InitializeFn),
        ("finalize", VoidFn),
        ("start_maintenance", MaintenanceFn),
        ("is_maintenance_mode", VoidFn),
        ("join_maintenance_thread", VoidFn),
        ("deployer_initialize", InitializeFn),
        ("prebuild", VoidFn),
        ("deploy", VoidFn),
        ("deploy_schema", ctypes.c_void_p),
        ("deploy_config_file", ctypes.c_void_p),
        ("sync_user_data", VoidFn),
        ("create_session", CreateSessionFn),
        ("find_session", FindSessionFn),
        ("destroy_session", DestroySessionFn),
        ("cleanup_stale_sessions", VoidFn),
        ("cleanup_all_sessions", VoidFn),
        ("process_key", ProcessKeyFn),
        ("commit_composition", CommitCompositionFn),
        ("clear_composition", ClearCompositionFn),
        ("get_commit", GetCommitFn),
        ("free_commit", FreeCommitFn),
        ("get_context", GetContextFn),
        ("free_context", FreeContextFn),
        # The fields below are not used, but preserve the published API
        # layout if a newer DLL reads the structure size.
        ("get_status", ctypes.c_void_p),
        ("free_status", ctypes.c_void_p),
        ("set_option", ctypes.c_void_p),
        ("get_option", ctypes.c_void_p),
        ("set_property", ctypes.c_void_p),
        ("get_property", ctypes.c_void_p),
        ("get_schema_list", ctypes.c_void_p),
        ("free_schema_list", ctypes.c_void_p),
        ("get_current_schema", ctypes.c_void_p),
        ("select_schema", SelectSchemaFn),
    ]


def is_hanzi(ch: str) -> bool:
    value = ord(ch)
    return 0x3400 <= value <= 0x4DBF or 0x4E00 <= value <= 0x9FFF


def fetch_article() -> str:
    query = urllib.parse.urlencode(
        {
            "action": "parse",
            "oldid": str(PINNED_REVISION),
            "prop": "text",
            "variant": "zh-tw",
            "format": "json",
            "formatversion": "2",
        }
    )
    request = urllib.request.Request(
        f"{WIKIPEDIA_API}?{query}",
        headers={"User-Agent": "weasel-article-regression/1.0"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.load(response)
    source = payload["parse"]["text"]
    paragraphs = []
    for match in re.finditer(r"<p\b[^>]*>(.*?)</p>", source, re.I | re.S):
        text = match.group(1)
        text = re.sub(r"<sup\b[^>]*>.*?</sup>", "", text, flags=re.I | re.S)
        text = re.sub(r"<[^>]+>", "", text)
        text = html.unescape(text)
        text = re.sub(r"\[[^\]]*\]", "", text)
        text = re.sub(r"\s+", " ", text).strip()
        if len(text) >= 80:
            paragraphs.append(text)
    if not paragraphs:
        raise RuntimeError("Wikipedia revision returned no readable paragraphs")
    return "\n".join(paragraphs)


def parse_dictionary(path: Path):
    entries = []
    with path.open("r", encoding="utf-8") as source:
        for line in source:
            if "\t" not in line or line.lstrip().startswith("#"):
                continue
            fields = line.rstrip("\r\n").split("\t")
            if len(fields) < 2:
                continue
            text, code = fields[0].strip(), fields[1].strip()
            if text and code and all(is_hanzi(ch) for ch in text):
                entries.append((text, code))
    return entries


def build_cases(user_dir: Path, article: str):
    phrase_map = {}
    char_map = {}
    for path in (user_dir / "common_words_import.dict.yaml", user_dir / "dayi2.dict.yaml"):
        if not path.exists():
            continue
        for text, code in parse_dictionary(path):
            if len(text) == 1:
                char_map.setdefault(text, code)
            elif path.name == "common_words_import.dict.yaml":
                phrase_map.setdefault(text, code)

    phrases_by_first = {}
    for phrase in phrase_map:
        phrases_by_first.setdefault(phrase[0], []).append(phrase)
    for values in phrases_by_first.values():
        values.sort(key=len, reverse=True)

    cases = []
    unsupported = 0
    index = 0
    while index < len(article):
        char = article[index]
        if not is_hanzi(char):
            index += 1
            continue
        match = None
        for phrase in phrases_by_first.get(char, []):
            if article.startswith(phrase, index):
                match = phrase
                break
        if match is None:
            match = char if char in char_map else None
        if match is None:
            unsupported += 1
            index += 1
            continue
        code = phrase_map.get(match, char_map.get(match))
        cases.append((match, code))
        index += len(match)
    return cases, unsupported


def copy_tree_best_effort(source: Path, destination: Path):
    """Copy immutable userdb files without failing on files locked by Weasel."""
    destination.mkdir(parents=True, exist_ok=True)
    complete = True
    for item in source.iterdir():
        target = destination / item.name
        if item.is_dir():
            complete = copy_tree_best_effort(item, target) and complete
            continue
        if item.name == "LOCK" or item.suffix == ".log":
            continue
        try:
            shutil.copy2(item, target)
        except OSError:
            complete = False
    return complete


def copy_snapshot(source: Path, destination: Path, include_userdb: bool = False):
    destination.mkdir(parents=True, exist_ok=True)
    userdb_copied = False
    for item in source.iterdir():
        if item.name == "sync":
            continue
        target = destination / item.name
        if item.name == "common_words.userdb" and item.is_dir():
            if include_userdb:
                complete = copy_tree_best_effort(item, target)
                current = target / "CURRENT"
                manifest = None
                if current.exists():
                    manifest_name = current.read_text(encoding="utf-8").strip()
                    manifest = target / manifest_name
                if complete and manifest and manifest.exists():
                    userdb_copied = True
                else:
                    shutil.rmtree(target, ignore_errors=True)
        elif item.name == "lua" and item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        elif item.name == "build" and item.is_dir():
            copy_tree_best_effort(item, target)
        elif item.is_file() and item.suffix in {".yaml", ".txt"}:
            shutil.copy2(item, target)
    return userdb_copied


def load_rime(dll_path: Path, shared_dir: Path, user_dir: Path):
    if hasattr(os, "add_dll_directory"):
        os.add_dll_directory(str(dll_path.parent))
    dll = ctypes.CDLL(str(dll_path))
    dll.rime_get_api.restype = ctypes.POINTER(RimeApi)
    api = dll.rime_get_api()
    if not api:
        raise RuntimeError("rime_get_api returned null")

    values = [
        str(shared_dir).encode(),
        str(user_dir).encode(),
        b"Weasel",
        b"weasel",
        b"0.17.4",
        b"rime.article.regression",
    ]
    traits = RimeTraits()
    traits.data_size = ctypes.sizeof(RimeTraits) - ctypes.sizeof(ctypes.c_int)
    traits.shared_data_dir = values[0]
    traits.user_data_dir = values[1]
    traits.distribution_name = values[2]
    traits.distribution_code_name = values[3]
    traits.distribution_version = values[4]
    traits.app_name = values[5]
    traits.prebuilt_data_dir = str(user_dir / "build").encode()
    api.contents.setup(ctypes.byref(traits))
    api.contents.initialize(None)
    if api.contents.start_maintenance(0):
        api.contents.join_maintenance_thread()
    session = api.contents.create_session()
    if not session:
        api.contents.finalize()
        raise RuntimeError("unable to create Rime session")
    if not api.contents.select_schema(session, b"dayi2"):
        api.contents.destroy_session(session)
        api.contents.finalize()
        raise RuntimeError("unable to select dayi2 schema")
    return dll, api.contents, session, values, traits


def automatic_result(api, session, key_sequence: str):
    api.clear_composition(session)
    for key in key_sequence:
        api.process_key(session, ord(key), 0)
    before_commit = current_candidates(api, session)
    # Space confirms the final segment's highlighted candidate.  The explicit
    # commit then makes the result observable without touching the live userdb.
    api.process_key(session, ord(" "), 0)
    api.commit_composition(session)
    commit = RimeCommit()
    commit.data_size = ctypes.sizeof(RimeCommit) - ctypes.sizeof(ctypes.c_int)
    committed = ""
    if api.get_commit(session, ctypes.byref(commit)):
        committed = (commit.text or b"").decode("utf-8", "replace")
        api.free_commit(ctypes.byref(commit))

    # Keep the pre-commit menu as diagnostics when a composition did not commit.
    return committed, before_commit


def current_candidates(api, session):
    context = RimeContext()
    context.data_size = ctypes.sizeof(RimeContext) - ctypes.sizeof(ctypes.c_int)
    if not api.get_context(session, ctypes.byref(context)):
        raise RuntimeError("Rime get_context failed")
    values = []
    for index in range(min(context.menu.num_candidates, 5)):
        candidate = context.menu.candidates[index]
        values.append((candidate.text or b"").decode("utf-8", "replace"))
    api.free_context(ctypes.byref(context))
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rime-dir", type=Path, default=Path(os.environ.get("APPDATA", "")) / "Rime")
    parser.add_argument("--dll", type=Path, default=Path(r"C:\Program Files\Rime\weasel-0.17.4\rime.dll"))
    parser.add_argument("--shared-dir", type=Path, default=Path(r"C:\Program Files\Rime\weasel-0.17.4\data"))
    parser.add_argument("--max-cases", type=int, default=0)
    parser.add_argument("--min-top1", type=float, default=0.0)
    parser.add_argument("--show-failures", type=int, default=20)
    parser.add_argument(
        "--spaced-codes",
        action="store_true",
        help="keep dictionary delimiters; default tests continuous typing",
    )
    parser.add_argument(
        "--include-userdb",
        action="store_true",
        help="best-effort copy of learned common_words.userdb (may be locked)",
    )
    args = parser.parse_args()

    if not args.rime_dir.exists():
        raise SystemExit(f"Rime user directory not found: {args.rime_dir}")
    if not args.dll.exists():
        raise SystemExit(f"Rime DLL not found: {args.dll}")

    article = fetch_article()
    cases, unsupported = build_cases(args.rime_dir, article)
    if args.max_cases:
        cases = cases[: args.max_cases]
    if not cases:
        raise SystemExit("No test cases could be derived from the article")

    failures = []
    with tempfile.TemporaryDirectory(prefix="rime-article-test-") as temp:
        snapshot = Path(temp)
        userdb_copied = copy_snapshot(
            args.rime_dir, snapshot, include_userdb=args.include_userdb
        )
        _, api, session, _values, _traits = load_rime(args.dll, args.shared_dir, snapshot)
        try:
            for expected, code in cases:
                input_code = code if args.spaced_codes else code.replace(" ", "")
                actual, candidates = automatic_result(api, session, input_code)
                if not actual:
                    actual = candidates[0] if candidates else "<no candidate>"
                if actual != expected:
                    failures.append((expected, input_code, actual, candidates))
        finally:
            api.destroy_session(session)
            api.finalize()

    correct = len(cases) - len(failures)
    top1 = correct / len(cases)
    phrase_total = sum(len(expected) > 1 for expected, _code in cases)
    char_total = len(cases) - phrase_total
    phrase_failures = sum(len(expected) > 1 for expected, _code, _actual, _candidates in failures)
    char_failures = len(failures) - phrase_failures
    print(f"Wikipedia {WIKIPEDIA_TITLE} revision {PINNED_REVISION}")
    print(f"revision_timestamp={PINNED_TIMESTAMP} source={WIKIPEDIA_PAGE_URL}")
    if args.include_userdb and not userdb_copied:
        userdb_mode = "excluded (live files locked or incomplete)"
    elif userdb_copied:
        userdb_mode = "included"
    else:
        userdb_mode = "excluded (static baseline)"
    print(f"userdb={userdb_mode} code_mode={'spaced' if args.spaced_codes else 'continuous'}")
    print(f"cases={len(cases)} unsupported_hanzi={unsupported} top1={top1:.3%}")
    if phrase_total:
        print(
            f"phrase_top1={(phrase_total - phrase_failures) / phrase_total:.3%} "
            f"({phrase_total - phrase_failures}/{phrase_total})"
        )
    if char_total:
        print(
            f"character_top1={(char_total - char_failures) / char_total:.3%} "
            f"({char_total - char_failures}/{char_total})"
        )
    confusions = Counter(
        (expected, actual)
        for expected, _code, actual, _candidates in failures
        if len(expected) == 1 and len(actual) == 1
    )
    if confusions:
        print("character_confusions=" + ", ".join(
            f"{expected}->{actual}:{count}"
            for (expected, actual), count in confusions.most_common(20)
        ))
    for expected, code, actual, candidates in failures[: args.show_failures]:
        print(f"FAIL expected={expected!r} code={code!r} actual={actual!r} candidates={candidates!r}")
    if top1 < args.min_top1:
        print(f"FAIL top1 {top1:.3%} < required {args.min_top1:.3%}")
        return 1
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(130)
