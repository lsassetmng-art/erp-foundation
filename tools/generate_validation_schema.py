#!/usr/bin/env python3
from pathlib import Path
import re
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "app/src/main/java"
OUT = ROOT / "spec/validation.schema.yaml"

# Input DTO をざっくり探索: *Input.java
inputs = sorted(SRC.rglob("*Input.java"))

def extract_fields(java_text: str):
    # 例: private final String orderNo;
    #     private int qty;
    fields = []
    for m in re.finditer(r'^\s*private\s+(?:final\s+)?([A-Za-z0-9_<>\[\].]+)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;', java_text, re.M):
        typ, name = m.group(1), m.group(2)
        fields.append((name, typ))
    # 例: public final String orderNo;
    for m in re.finditer(r'^\s*public\s+(?:final\s+)?([A-Za-z0-9_<>\[\].]+)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;', java_text, re.M):
        typ, name = m.group(1), m.group(2)
        fields.append((name, typ))
    # 重複除去（順序保持）
    seen = set()
    uniq = []
    for n,t in fields:
        if n in seen: 
            continue
        seen.add(n)
        uniq.append((n,t))
    return uniq

def guess_rules(name: str, typ: str):
    rules = {}
    # 必須：プリミティブは必須扱い、Stringは任意だがよく使うものは必須に寄せる
    if typ in ("int","long","double","float","boolean","Integer","Long","Double","Float","Boolean"):
        rules["required"] = True
    elif typ.lower().endswith("string"):
        # よくある必須っぽい名前
        if name.endswith(("no","code","id","email","password","token","key")):
            rules["required"] = True
        else:
            rules["required"] = False
        rules["minLen"] = 1 if rules["required"] else 0
        # 桁数のデフォルト（安全側：上限だけ付ける）
        rules["maxLen"] = 255
    else:
        rules["required"] = False
    # 数値系の下限（安全）
    if typ in ("int","long","Integer","Long"):
        rules["min"] = 0
    return rules

lines = []
lines.append(f"# Auto generated at {datetime.now().isoformat(timespec='seconds')}")
lines.append("version: 1")
lines.append("rules:")

for p in inputs:
    text = p.read_text(encoding="utf-8", errors="ignore")
    cls = p.stem
    fields = extract_fields(text)
    if not fields:
        continue
    lines.append(f"  {cls}:")
    for name, typ in fields:
        r = guess_rules(name, typ)
        lines.append(f"    {name}:")
        for k,v in r.items():
            if isinstance(v, bool):
                vv = "true" if v else "false"
                lines.append(f"      {k}: {vv}")
            elif isinstance(v, (int,float)):
                lines.append(f"      {k}: {v}")
            else:
                lines.append(f"      {k}: \"{v}\"")

OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"OK: generated {OUT.relative_to(ROOT)} from {len(inputs)} input DTO files")
