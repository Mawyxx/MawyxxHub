#!/usr/bin/env python3
"""Bundle src/MawyxxHub → dist/MawyxxHub.lua + dist/demo.lua + dist/demo_play.lua."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "src" / "MawyxxHub"
DIST = Path(__file__).resolve().parent.parent / "dist"
OUT = DIST / "MawyxxHub.lua"
DEMO_OUT = DIST / "demo.lua"

REQUIRE_RE = re.compile(r"require\((script(?:\.[A-Za-z_][A-Za-z0-9_]*)+)\)")


def module_id(path: Path) -> str:
    rel = path.relative_to(ROOT).as_posix()
    if rel == "init.lua":
        return "init"
    return rel[: -len(".lua")]


def dir_parts(mid: str) -> list[str]:
    if mid == "init":
        return []
    return mid.split("/")[:-1]


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

    resolved = "/".join(cursor).removesuffix("/__mod__")
    if resolved in ("__mod__", ""):
        resolved = "init"
    return resolved


def rewrite(mid: str, src: str) -> str:
    def repl(m: re.Match[str]) -> str:
        return f'__require("{resolve(mid, m.group(1))}")'

    return REQUIRE_RE.sub(repl, src)


def main() -> None:
    files = sorted(ROOT.rglob("*.lua"))
    parts: list[str] = [
        "-- MawyxxHub — main framework bundle. Auto-generated; do not edit.",
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
        src = rewrite(mid, f.read_text(encoding="utf-8"))
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

    DIST.mkdir(parents=True, exist_ok=True)
    text = "\n".join(parts)
    OUT.write_text(text, encoding="utf-8", newline="\n")

    demo_path = Path(__file__).resolve().parent.parent / "examples" / "demo_inline.lua"
    run_parts = parts[:-2]
    run_parts.append("")
    run_parts.append("-- ===== DEMO =====")
    run_parts.extend(demo_path.read_text(encoding="utf-8").splitlines())
    run_parts.append("")
    DEMO_OUT.write_text("\n".join(run_parts), encoding="utf-8", newline="\n")

    play_path = Path(__file__).resolve().parent.parent / "examples" / "demo_play_inline.lua"
    PLAY_OUT = DIST / "demo_play.lua"
    play_parts = parts[:-2]
    play_parts.append("")
    play_parts.append("-- ===== PLAY DEMO =====")
    play_parts.extend(play_path.read_text(encoding="utf-8").splitlines())
    play_parts.append("")
    PLAY_OUT.write_text("\n".join(play_parts), encoding="utf-8", newline="\n")

    # Drop legacy versioned / alias files if present
    for stale in DIST.glob("___RUN*"):
        stale.unlink()
        print("removed", stale.name)
    for stale_name in ("MawyxxHub.bundle.lua", "MawyxxHub.hsv.lua"):
        p = DIST / stale_name
        if p.exists():
            p.unlink()
            print("removed", stale_name)

    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes, {len(files)} modules, leftover={leftover})")
    print(f"Wrote {DEMO_OUT} ({DEMO_OUT.stat().st_size} bytes)")
    print(f"Wrote {PLAY_OUT} ({PLAY_OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
