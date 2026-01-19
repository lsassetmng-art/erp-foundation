import os, re, datetime

ROOT = "."
OUT = "reports/ui_review.md"
os.makedirs("reports", exist_ok=True)

now = datetime.datetime.now().isoformat(timespec="seconds")
issues = []
summary = []

# 1) Activity: setContentView未設定を列挙（XML運用の前提）
for root, _, files in os.walk("app/src/main/java/app/activity"):
    for f in files:
        if f.endswith("Activity.java"):
            p = os.path.join(root, f)
            txt = open(p, "r", encoding="utf-8").read()
            if "setContentView(" not in txt:
                issues.append(f"- {p}: setContentView 未設定（XML/Composeどちらかに統一すると良い）")
            summary.append(f"- Activity: {p}")

# 2) XML: 画面名表示だけか（最低UI）をチェック
for root, _, files in os.walk("app/src/main/res/layout"):
    for f in files:
        if f.startswith("activity_") and f.endswith(".xml"):
            p = os.path.join(root, f)
            txt = open(p, "r", encoding="utf-8").read()
            if "<TextView" not in txt:
                issues.append(f"- {p}: TextView無し（最低表示要素不足の可能性）")
            summary.append(f"- XML: {p}")

# 3) Compose: 生成されたScreenの存在確認
for root, _, files in os.walk("app/src/main/java/app/ui/compose"):
    for f in files:
        if f.endswith("Screen.kt"):
            p = os.path.join(root, f)
            summary.append(f"- Compose: {p}")

# 4) 禁止: company_id を UI 層で見つけたら即NG
ui_hits = []
for base in ["app/src/main/java/app/activity", "app/src/main/java/app/viewmodel", "app/src/main/res/layout"]:
    if not os.path.exists(base):
        continue
    for root, _, files in os.walk(base):
        for f in files:
            if f.endswith((".java",".kt",".xml")):
                p = os.path.join(root, f)
                txt = open(p, "r", encoding="utf-8", errors="ignore").read()
                if "company_id" in txt:
                    ui_hits.append(p)
if ui_hits:
    issues.append("## CRITICAL\n- UI層に company_id が出現: " + ", ".join(ui_hits))

with open(OUT, "w", encoding="utf-8") as out:
    out.write(f"# UI Review (Static)\n\n- generated_at: {now}\n\n")
    out.write("## Summary\n")
    out.write("\n".join(summary) + "\n\n")
    out.write("## Issues\n")
    out.write("\n".join(issues) if issues else "- None\n")

print("OK: UI review written to", OUT)
