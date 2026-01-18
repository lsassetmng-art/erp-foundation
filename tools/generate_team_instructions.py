#!/usr/bin/env python3
import yaml, pathlib

SPEC = pathlib.Path("spec/usecases.schema.yaml")
OUT  = pathlib.Path("reports/team_instructions.md")

data = yaml.safe_load(SPEC.read_text(encoding="utf-8"))
usecases = data.get("usecases", [])

lines = []
lines.append("# チーム別指示書（自動生成）\n")

roles = {
    "Architect": [],
    "Backend": [],
    "Mobile": [],
}

for uc in usecases:
    domain = uc["domain"]
    name   = uc["name"]
    utype  = uc["type"]

    roles["Architect"].append(
        f"- {domain}/{name}: レイヤ構成・責務境界・RLS前提設計を確認"
    )

    roles["Backend"].append(
        f"- {domain}/{name}: Repository / RPC / DTO 実装"
    )

    roles["Mobile"].append(
        f"- {domain}/{name}: ViewModel / UseCase 呼び出し"
    )

for role, items in roles.items():
    lines.append(f"\n## {role}\n")
    lines.extend(items)

OUT.write_text("\n".join(lines), encoding="utf-8")
print("OK: generated", OUT)
