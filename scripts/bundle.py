#!/usr/bin/env python3
"""Bundle src/MawyxxHub into dist/ for HttpGet + loadstring."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "src" / "MawyxxHub"
OUT = Path(__file__).resolve().parent.parent / "dist" / "MawyxxHub.lua"
# Current single-file demo (bump when HttpGet cache must be busted)
RUN_NAME = "___RUN_UI_V19.lua"

REQUIRE_RE = re.compile(r"require\((script(?:\.[A-Za-z_][A-Za-z0-9_]*)+)\)")


def module_id(path: Path) -> str:
    rel = path.relative_to(ROOT).as_posix()
    if rel == "init.lua":
        return "init"
    return rel[: -len(".lua")]


def dir_parts(mid: str) -> list[str]:
    if mid == "init":
        return []
    parts = mid.split("/")
    return parts[:-1]


def resolve(mid: str, expr: str) -> str:
    tokens = [t for t in expr.replace("script", "", 1).split(".") if t]
    cursor: list[str] = list(dir_parts(mid))
    if mid != "init":
        cursor.append("__mod__")

    for t in tokens:
        if t == "Parent":
            if not cursor:
                raise RuntimeError(f"Parent past root in {mid} :: {expr}")
            cursor.pop()
        else:
            cursor.append(t)

    resolved = "/".join(cursor)
    resolved = resolved.removesuffix("/__mod__")
    if resolved == "__mod__" or resolved == "":
        resolved = "init"
    return resolved


def rewrite(mid: str, src: str) -> str:
    def repl(m: re.Match[str]) -> str:
        expr = m.group(1)
        rid = resolve(mid, expr)
        return f'__require("{rid}")'

    return REQUIRE_RE.sub(repl, src)


def main() -> None:
    files = sorted(ROOT.rglob("*.lua"))
    parts: list[str] = [
        "-- MawyxxHub bundled for HttpGet/loadstring. Auto-generated; do not edit.",
        "local __modules = {}",
        "local __loaded = {}",
        "local function __require(id)",
        "\tif __loaded[id] then return __loaded[id] end",
        "\tlocal loader = __modules[id]",
        '\tif not loader then error("[MawyxxHub] module not found: " .. tostring(id), 2) end',
        "\tlocal export = loader(__require)",
        "\t__loaded[id] = export",
        "\treturn export",
        "end",
        "",
    ]

    leftover = 0
    for f in files:
        mid = module_id(f)
        src = f.read_text(encoding="utf-8")
        src = rewrite(mid, src)
        if "require(script" in src:
            leftover += 1
            print("WARN leftover require(script in", mid)
        parts.append(f'__modules["{mid}"] = function(__require)')
        for line in src.splitlines():
            parts.append("\t" + line)
        parts.append("end")
        parts.append("")

    parts.append('return __require("init")')
    parts.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    text = "\n".join(parts)
    OUT.write_text(text, encoding="utf-8", newline="\n")
    # Keep one alt name for docs that still reference .bundle.lua
    (OUT.parent / "MawyxxHub.bundle.lua").write_text(text, encoding="utf-8", newline="\n")

    demo_path = Path(__file__).resolve().parent.parent / "examples" / "demo_inline.lua"
    demo = demo_path.read_text(encoding="utf-8")
    run_parts = parts[:-2]
    run_parts.append("")
    run_parts.append("-- ===== INLINE DEMO =====")
    for line in demo.splitlines():
        run_parts.append(line)
    run_parts.append("")
    run_text = "\n".join(run_parts)
    run_out = OUT.parent / RUN_NAME
    run_out.write_text(run_text, encoding="utf-8", newline="\n")
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes, {len(files)} modules, leftover={leftover})")
    print(f"Wrote {run_out} ({run_out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
