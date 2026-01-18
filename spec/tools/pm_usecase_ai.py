#!/usr/bin/env python3
import os, re, sys
from datetime import datetime
import yaml

ROOT = os.getcwd()
REQ = os.path.join(ROOT, "pm_ai", "requirements.md")
POL = os.path.join(ROOT, "pm_ai", "pm_policy.yaml")
OUT_SPEC = os.path.join(ROOT, "spec", "usecases.schema.yaml")
OUT_MAP = os.path.join(ROOT, "reports", "usecase_map.yaml")
OUT_INSTR = os.path.join(ROOT, "reports", "team_instructions.md")

os.makedirs(os.path.dirname(OUT_SPEC), exist_ok=True)
os.makedirs(os.path.dirname(OUT_MAP), exist_ok=True)
os.makedirs(os.path.dirname(OUT_INSTR), exist_ok=True)

policy = yaml.safe_load(open(POL, "r", encoding="utf-8"))["pm_usecase_ai"]
FORBID = set(t.lower() for t in policy["forbid_tokens"])
NAME_RE = re.compile(policy["naming"]["pattern"])
DOMAIN_ALLOWED = set(policy["domains_allowed"])

DOMAIN_HINT_RE = re.compile(r"^\s*-\s*\[domain:([a-zA-Z0-9_-]+)\]\s*(.*)$")

# Deterministic mapping (extendable)
MAP = [
    (r"(ログイン|認証)", "auth", "AuthenticateUser", "command"),
    (r"(ログアウト)", "auth", "Logout", "command"),
    (r"(受注).*(登録|作成)", "order", "CreateOrder", "command"),
    (r"(受注).*(確定)", "order", "ConfirmOrder", "command"),
    (r"(受注).*(一覧)", "order", "GetOrderList", "query"),
    (r"(出荷).*(登録|作成)", "shipping", "CreateShipping", "command"),
    (r"(請求書|請求).*(作成|発行)", "billing", "CreateInvoice", "command"),
    (r"(請求書|請求).*(一覧)", "billing", "GetInvoiceList", "query"),
]

def forbid_check(text):
    low = text.lower()
    for t in FORBID:
        if t in low:
            raise SystemExit(f"FORBIDDEN token detected: {t}")

def main():
    if not os.path.isfile(REQ):
        raise SystemExit("pm_ai/requirements.md not found")

    lines = open(REQ, "r", encoding="utf-8").read().splitlines()
    usecases, seen = [], set()
    map_rows = []

    for raw in lines:
        if not raw.strip() or raw.strip().startswith("#"): continue
        domain_hint = None
        body = raw
        m = DOMAIN_HINT_RE.match(raw)
        if m:
            domain_hint = m.group(1)
            body = "- " + m.group(2)

        text = re.sub(r"^\s*-\s*", "", body).strip()
        forbid_check(text)

        found = None
        for pat, dom, name, typ in MAP:
            if re.search(pat, text):
                if domain_hint: dom = domain_hint
                found = (dom, name, typ)
                break

        if not found:
            # safe fallback
            dom = domain_hint or "system"
            name = "GetAppConfig"
            typ = "query"
            found = (dom, name, typ)

        dom, name, typ = found
        if dom not in DOMAIN_ALLOWED:
            raise SystemExit(f"DOMAIN not allowed: {dom}")
        if not NAME_RE.match(name):
            raise SystemExit(f"INVALID usecase name: {name}")

        key = (dom, name)
        status = "ok"
        if key in seen:
            status = "dedup"
        else:
            seen.add(key)
            usecases.append({"domain": dom, "name": name, "type": typ})

        map_rows.append({"requirement": text, "domain": dom, "usecase": name, "type": typ, "status": status})

    with open(OUT_SPEC, "w", encoding="utf-8") as f:
        f.write("usecases:\n\n")
        for u in usecases:
            f.write(f"  - domain: {u['domain']}\n")
            f.write(f"    name: {u['name']}\n")
            f.write(f"    type: {u['type']}\n\n")

    now = datetime.now().isoformat()
    with open(OUT_MAP, "w", encoding="utf-8") as f:
        yaml.safe_dump({"generated_at": now, "items": map_rows}, f, allow_unicode=True)

    teams = {}
    for u in usecases:
        teams.setdefault(u["domain"], []).append(u["name"])

    with open(OUT_INSTR, "w", encoding="utf-8") as f:
        f.write(f"# Team Instructions\nGenerated: {now}\n\n")
        for d in sorted(teams):
            f.write(f"## {d} team\n")
            for n in teams[d]:
                f.write(f"- Implement UseCase: {n}\n")
            f.write("\n")

    print("OK: PM-UseCase-AI generated spec & reports")

if __name__ == "__main__":
    main()
