#!/usr/bin/env python3
import yaml, pathlib, sys

OLD = pathlib.Path("spec/usecases.prev.yaml")
CUR = pathlib.Path("spec/usecases.schema.yaml")
OUT = pathlib.Path("reports/spec_diff.md")

if not OLD.exists():
    OLD.write_text(CUR.read_text(encoding="utf-8"), encoding="utf-8")
    OUT.write_text("Initial spec snapshot created\n", encoding="utf-8")
    print("OK: initial snapshot")
    sys.exit(0)

old = yaml.safe_load(OLD.read_text(encoding="utf-8")).get("usecases", [])
cur = yaml.safe_load(CUR.read_text(encoding="utf-8")).get("usecases", [])

old_set = {(u["domain"], u["name"]) for u in old}
cur_set = {(u["domain"], u["name"]) for u in cur}

added = cur_set - old_set
removed = old_set - cur_set

lines = ["# Spec Diff\n"]
if added:
    lines.append("## Added")
    for d,n in added:
        lines.append(f"- {d}/{n}")
if removed:
    lines.append("## Removed")
    for d,n in removed:
        lines.append(f"- {d}/{n}")

OUT.write_text("\n".join(lines), encoding="utf-8")
OLD.write_text(CUR.read_text(encoding="utf-8"), encoding="utf-8")

print("OK: spec diff generated")
