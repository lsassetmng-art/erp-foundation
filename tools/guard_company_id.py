#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "app/src/main/java"
hits = []

for p in SRC.rglob("*.java"):
    if "company_id" in p.read_text(encoding="utf-8", errors="ignore"):
        hits.append(str(p.relative_to(ROOT)))

if hits:
    print("NG: company_id usage detected")
    for h in hits:
        print(" -", h)
    sys.exit(1)

print("OK: no company_id leakage")
