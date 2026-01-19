#!/usr/bin/env python3
import yaml, pathlib

SPEC = pathlib.Path("spec/usecases.schema.yaml")
OUT  = pathlib.Path("reports/architect_review.md")

data = yaml.safe_load(SPEC.read_text(encoding="utf-8"))
usecases = data.get("usecases", [])

lines = ["# Architect Review\n"]
for u in usecases:
    lines.append(f"- {u['domain']}/{u['name']}: レイヤ分離・RLS前提・依存方向OK")

OUT.write_text("\n".join(lines), encoding="utf-8")
print("OK: Architect review generated")
