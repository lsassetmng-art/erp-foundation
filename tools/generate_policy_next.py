#!/usr/bin/env python3
from pathlib import Path
import sys
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "reports/ai_review_gate.json"
OUT = ROOT / "policies/policy_next.yaml"

if not REPORT.exists():
    print("OK: no review report (nothing to update)")
    sys.exit(0)

data = REPORT.read_text(encoding="utf-8", errors="ignore")

lines = []
lines.append(f"# Auto-generated policy_next.yaml")
lines.append(f"# {datetime.now().isoformat(timespec='seconds')}")
lines.append("next_actions:")

if "failed" in data and "[]" not in data:
    lines.append("  - tighten_validation: true")
    lines.append("  - require_additional_tests: true")
    lines.append("  - restrict_rpc_output_mapping: true")
else:
    lines.append("  - expand_usecases: true")
    lines.append("  - generate_additional_ui: true")

OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"OK: policy_next.yaml generated -> {OUT.relative_to(ROOT)}")
