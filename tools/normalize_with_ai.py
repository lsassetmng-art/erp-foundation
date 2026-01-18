#!/usr/bin/env python3
import os
import json
import yaml
import requests

API_KEY = os.environ.get("OPENAI_API_KEY")
if not API_KEY:
    raise RuntimeError("OPENAI_API_KEY not set")

ROOT = os.path.expanduser("~/erp-foundation")
IN_YAML = os.path.join(ROOT, "spec/usecases.auto.yaml")
OUT_YAML = os.path.join(ROOT, "spec/usecases.yaml")

with open(IN_YAML, "r", encoding="utf-8") as f:
    raw_yaml = f.read()

SYSTEM = """You are a senior ERP architect.
Normalize the YAML usecases safely.

Rules:
- Do NOT change flow order, only normalize terms.
- Allowed flow terms: validate, list, get, create, update, delete
- Normalize name to UpperCamelCase VerbNoun.
- Normalize rpc name to: rpc_<domain>_<action>
- Remove unsafe or unclear usecases.
- Do NOT mention company_id, SQL, HTTP, tables.
- Output ONLY valid YAML.
"""

payload = {
    "model": "gpt-4o-mini",
    "messages": [
        {"role": "system", "content": SYSTEM},
        {"role": "user", "content": raw_yaml}
    ],
    "temperature": 0
}

res = requests.post(
    "https://api.openai.com/v1/chat/completions",
    headers={
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    },
    json=payload,
    timeout=60
)

res.raise_for_status()
content = res.json()["choices"][0]["message"]["content"]

# Validate YAML
parsed = yaml.safe_load(content)
with open(OUT_YAML, "w", encoding="utf-8") as w:
    yaml.dump(parsed, w, allow_unicode=True, sort_keys=False)

print("OK: normalized YAML written to spec/usecases.yaml")
