#!/usr/bin/env python3
import os
import re
import yaml

OLD_SRC = os.path.expanduser("~/old-erp-src")
OUT = os.path.expanduser("~/erp-foundation/spec/usecases.auto.yaml")

USECASE_VERBS = [
    "create", "add", "update", "delete",
    "list", "get", "fetch"
]

usecases = []

def detect_flow(lines):
    flow = []
    for l in lines:
        l = l.strip()
        if "validate" in l:
            flow.append("validate")
        elif ".create" in l or "insert" in l:
            flow.append("create")
        elif ".update" in l:
            flow.append("update")
        elif ".delete" in l:
            flow.append("delete")
        elif ".list" in l or ".fetch" in l:
            flow.append("list")
    return list(dict.fromkeys(flow))  # 重複除去

for root, _, files in os.walk(OLD_SRC):
    for f in files:
        if not f.endswith(".java"):
            continue
        path = os.path.join(root, f)
        with open(path, encoding="utf-8", errors="ignore") as r:
            lines = r.readlines()

        for i, line in enumerate(lines):
            m = re.search(r"void\s+(\w+)\(", line)
            if not m:
                continue
            name = m.group(1).lower()

            if not any(v in name for v in USECASE_VERBS):
                continue

            block = lines[i:i+50]
            flow = detect_flow(block)
            if not flow:
                continue

            domain = os.path.basename(root).replace("Activity", "").lower()
            uc_name = name.title().replace("_", "")

            usecases.append({
                "domain": domain or "common",
                "name": uc_name,
                "flow": flow,
                "rpc": { flow[-1]: f"rpc_{domain}_{flow[-1]}" }
            })

spec = {"usecases": usecases}

with open(OUT, "w", encoding="utf-8") as w:
    yaml.dump(spec, w, allow_unicode=True, sort_keys=False)

print(f"OK: extracted {len(usecases)} usecases -> {OUT}")
