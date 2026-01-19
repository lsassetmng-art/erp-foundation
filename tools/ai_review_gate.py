#!/usr/bin/env python3
from pathlib import Path
import json, sys

ROOT = Path(__file__).resolve().parents[1]
REP_JSON = ROOT / "reports/ai_review_gate.json"
REP_MD   = ROOT / "reports/ai_review_gate.md"

checks = {
    "repository_exists": (ROOT / "app/src/main/java/app/repository").exists(),
    "usecase_exists":    (ROOT / "app/src/main/java/app/usecase").exists(),
    "ui_tests_exist":    (ROOT / "app/src/androidTest/java/app/ui").exists(),
}

failed = [k for k,v in checks.items() if not v]

REP_JSON.write_text(json.dumps({"checks": checks, "failed": failed}, indent=2), encoding="utf-8")
REP_MD.write_text("# AI Review Gate\n\n" + ("\n".join(failed) if failed else "ALL PASSED"), encoding="utf-8")

if failed:
    print("NG: AI review gate failed")
    sys.exit(1)

print("OK: AI review gate passed")
