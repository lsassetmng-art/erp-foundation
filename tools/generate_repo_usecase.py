#!/usr/bin/env python3
from pathlib import Path
import sys, json

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "spec/usecases.schema.yaml"
REPO = ROOT / "app/src/main/java/app/repository"
UC   = ROOT / "app/src/main/java/app/usecase"
REPO.mkdir(parents=True, exist_ok=True)
UC.mkdir(parents=True, exist_ok=True)

if not SPEC.exists():
    print("ERROR: usecases.schema.yaml not found")
    sys.exit(1)

import re
text = SPEC.read_text(encoding="utf-8", errors="ignore")

# 超簡易抽出（domain/name）
pairs = re.findall(r'-\s*name:\s*([A-Za-z0-9_]+)', text)
if not pairs:
    print("ERROR: no usecases found")
    sys.exit(1)

for name in pairs:
    # Repository
    (REPO / f"{name}Repository.java").write_text(f"""
package app.repository;

public final class {name}Repository {{
    public Object callRpc(Object input) {{
        // Supabase RPC call here (RLS enforced)
        return null;
    }}
}}
""".strip(), encoding="utf-8")

    # UseCase
    (UC / f"{name}UseCase.java").write_text(f"""
package app.usecase;

import app.repository.{name}Repository;

public final class {name}UseCase {{
    private final {name}Repository repo = new {name}Repository();

    public void execute(Object input) {{
        repo.callRpc(input);
    }}
}}
""".strip(), encoding="utf-8")

print("OK: Repository / UseCase generated")
