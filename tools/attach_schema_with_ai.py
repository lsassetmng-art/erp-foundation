#!/usr/bin/env python3
import os, yaml, requests

API_KEY = os.environ.get("OPENAI_API_KEY")
if not API_KEY:
    raise RuntimeError("OPENAI_API_KEY not set")

ROOT = os.path.expanduser("~/erp-foundation")
IN_YAML = os.path.join(ROOT, "spec/usecases.yaml")
OUT_YAML = os.path.join(ROOT, "spec/usecases.schema.yaml")

with open(IN_YAML, "r", encoding="utf-8") as f:
    base_yaml = f.read()

SYSTEM = """You are a senior ERP architect.
Attach JSON input/output schemas to each usecase safely.

Rules:
- Do NOT change flow order.
- Add 'input_schema' and 'output_schema' per usecase.
- Use JSON Schema style (draft-07).
- No company_id, SQL, HTTP, table names.
- Unknown fields must be optional.
- Output ONLY valid YAML.
"""

payload = {
    "model": "gpt-4o-mini",
    "messages": [
        {"role": "system", "content": SYSTEM},
        {"role": "user", "content": base_yaml}
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

print("OK: schema-attached YAML written to spec/usecases.schema.yaml")
