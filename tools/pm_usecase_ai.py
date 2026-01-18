#!/usr/bin/env python3
import yaml, pathlib

REQ = pathlib.Path("pm_ai/requirements.md")
OUT = pathlib.Path("spec/usecases.schema.yaml")

rules = [
    ("ログイン", "auth", "AuthenticateUser", "command"),
    ("ログアウト", "auth", "LogoutUser", "command"),
    ("受注を登録", "order", "CreateOrder", "command"),
    ("受注を確定", "order", "ConfirmOrder", "command"),
    ("受注一覧", "order", "GetOrderList", "query"),
    ("出荷を登録", "shipping", "CreateShipping", "command"),
    ("請求書を作成", "billing", "CreateInvoice", "command"),
    ("請求書一覧", "billing", "GetInvoiceList", "query"),
]

usecases = []

text = REQ.read_text(encoding="utf-8")

for key, domain, name, utype in rules:
    if key in text:
        usecases.append({
            "domain": domain,
            "name": name,
            "type": utype
        })

OUT.parent.mkdir(exist_ok=True)

with OUT.open("w", encoding="utf-8") as f:
    yaml.dump({"usecases": usecases}, f, allow_unicode=True)

print("OK: generated", OUT)
