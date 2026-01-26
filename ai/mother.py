#!/usr/bin/env python3
import os, subprocess, sys, json, time
from pathlib import Path

ERP_HOME = Path(os.environ.get("ERP_HOME", str(Path.home() / "erp-foundation")))
BIN = ERP_HOME / "bin"
REPORTS = ERP_HOME / "reports"
REPORTS.mkdir(parents=True, exist_ok=True)

def run(cmd, *, check=True):
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (REPORTS / "mother_last.log").write_text(p.stdout, encoding="utf-8")
    if check and p.returncode != 0:
        print(p.stdout)
        return p.returncode
    print(p.stdout)
    return 0

def main():
    steps = [
        ("env", [str(BIN / "00_check_env.sh")]),
        ("dump", [str(BIN / "01_dump_schema.sh")]),
        ("curate", [str(BIN / "02_curate_official_ddl.sh")]),
        ("verify_rls", [str(BIN / "03_verify_no_rls.sh")]),
        ("company_id_rules", [str(BIN / "04_company_id_rules.sh")]),
        ("freeze", [str(BIN / "05_freeze_official.sh")]),
    ]

    started = time.strftime("%Y-%m-%d %H:%M:%S")
    status = {"started": started, "steps": []}

    for name, cmd in steps:
        rc = run(cmd, check=False)
        status["steps"].append({"name": name, "rc": rc})
        if rc != 0:
            status["rc"] = rc
            (REPORTS / "mother_status.json").write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")
            return rc

    status["rc"] = 0
    (REPORTS / "mother_status.json").write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")
    print("OK: mother pipeline completed")
    print(f"status: {REPORTS / 'mother_status.json'}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
