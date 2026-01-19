#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "spec/validation.schema.yaml"
OUT.parent.mkdir(exist_ok=True)

OUT.write_text("""fields:
  orderNo:
    required: true
    maxLength: 20
  qty:
    required: true
    min: 1
""", encoding="utf-8")

print("OK: validation.schema.yaml generated")
