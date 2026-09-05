#!/usr/bin/env python3
"""Query Squirrel/librime first candidates for a code sequence."""
from __future__ import annotations

import ctypes
import os
import sys
from pathlib import Path

SQUIRREL = Path("/Library/Input Methods/Squirrel.app")
DYLIB = SQUIRREL / "Contents/Frameworks/librime.1.dylib"
SHARED = SQUIRREL / "Contents/SharedSupport"
USER = Path.home() / "Library/Rime"


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


VoidFn = ctypes.CFUNCTYPE(None)
SetupFn = ctypes.CFUNCTYPE(None, ctypes.POINTER(RimeTraits))
InitializeFn = ctypes.CFUNCTYPE(None, ctypes.POINTER(RimeTraits))
MaintenanceFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_int)
CreateSessionFn = ctypes.CFUNCTYPE(ctypes.c_size_t)
DestroySessionFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t)
ProcessKeyFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.c_int, ctypes.c_int)
ClearCompositionFn = ctypes.CFUNCTYPE(None, ctypes.c_size_t)
GetContextFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.POINTER(RimeContext))
FreeContextFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.POINTER(RimeContext))
SelectSchemaFn = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_size_t, ctypes.c_char_p)


class RimeApi(ctypes.Structure):
    _fields_ = [
        ("data_size", ctypes.c_int),
        ("setup", SetupFn),
        ("set_notification_handler", ctypes.c_void_p),
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
        ("find_session", ctypes.c_void_p),
        ("destroy_session", DestroySessionFn),
        ("cleanup_stale_sessions", VoidFn),
        ("cleanup_all_sessions", VoidFn),
        ("process_key", ProcessKeyFn),
        ("commit_composition", ctypes.c_void_p),
        ("clear_composition", ClearCompositionFn),
        ("get_commit", ctypes.c_void_p),
        ("free_commit", ctypes.c_void_p),
        ("get_context", GetContextFn),
        ("free_context", FreeContextFn),
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


def decode(ptr) -> str:
    if not ptr:
        return ""
    if isinstance(ptr, bytes):
        return ptr.decode("utf-8", "replace")
    return ctypes.cast(ptr, ctypes.c_char_p).value.decode("utf-8", "replace")


def main() -> int:
    keys = sys.argv[1] if len(sys.argv) > 1 else "hzwq"
    schema = (sys.argv[2] if len(sys.argv) > 2 else "dayi2").encode()
    os.environ["DYLD_LIBRARY_PATH"] = str(SQUIRREL / "Contents/Frameworks")
    dll = ctypes.CDLL(str(DYLIB))
    dll.rime_get_api.restype = ctypes.POINTER(RimeApi)
    api = dll.rime_get_api().contents
    values = [
        str(SHARED).encode(),
        str(USER).encode(),
        b"Squirrel",
        b"Squirrel",
        b"1.0.3",
        b"rime.query",
        str(USER / "build").encode(),
    ]
    traits = RimeTraits()
    traits.data_size = ctypes.sizeof(RimeTraits) - ctypes.sizeof(ctypes.c_int)
    traits.shared_data_dir = values[0]
    traits.user_data_dir = values[1]
    traits.distribution_name = values[2]
    traits.distribution_code_name = values[3]
    traits.distribution_version = values[4]
    traits.app_name = values[5]
    traits.prebuilt_data_dir = values[6]
    traits.staging_dir = values[6]
    api.setup(ctypes.byref(traits))
    api.initialize(None)
    if api.start_maintenance(0):
        api.join_maintenance_thread()
    session = api.create_session()
    if not session:
        print("no session")
        return 1
    if not api.select_schema(session, schema):
        print("cannot select", schema)
        return 1
    api.clear_composition(session)
    for ch in keys:
        api.process_key(session, ord(ch), 0)
    ctx = RimeContext()
    ctx.data_size = ctypes.sizeof(RimeContext) - ctypes.sizeof(ctypes.c_int)
    api.get_context(session, ctypes.byref(ctx))
    preedit = decode(ctx.composition.preedit)
    preview = decode(ctx.commit_text_preview)
    print(f"schema={schema.decode()} keys={keys} preedit={preedit!r} preview={preview!r} n={ctx.menu.num_candidates}")
    for i in range(min(ctx.menu.num_candidates, 8)):
        cand = ctx.menu.candidates[i]
        print(f"{i+1}. {decode(cand.text)}")
    api.free_context(ctypes.byref(ctx))
    api.destroy_session(session)
    api.finalize()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
