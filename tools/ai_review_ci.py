#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "reports/ai_review_ui.md"
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"

errors = []

for vm in VM_DIR.glob("*ViewModel.java"):
    text = vm.read_text(encoding="utf-8")
    if "executeSafe" not in text:
        errors.append(f"{vm.name}: missing executeSafe")
    if "Map<String,String>" not in text:
        errors.append(f"{vm.name}: validation map missing")

REPORT.write_text(
    "# AI UI Review (CI)\n\n" +
    ("\n".join(errors) if errors else "ALL CHECKS PASSED"),
    encoding="utf-8"
)

if errors:
    print("NG: review failed")
    sys.exit(1)

print("OK: review passed")
sys.exit(0)
