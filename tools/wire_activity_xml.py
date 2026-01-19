import os, re, shutil

ACT_ROOT = "app/src/main/java/app/activity"
LAY_ROOT = "app/src/main/res/layout"

base_xml = os.path.join(LAY_ROOT, "_activity_base.xml")

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue
        ap = os.path.join(root, f)
        with open(ap, encoding="utf-8") as fp:
            src = fp.read()

        if "setContentView(" in src:
            continue  # already wired

        name = f.replace("Activity.java", "")
        layout_name = f"activity_{name.lower()}.xml"
        layout_path = os.path.join(LAY_ROOT, layout_name)

        # XML作成（共通テンプレから）
        if not os.path.exists(layout_path):
            shutil.copyfile(base_xml, layout_path)
            txt = open(layout_path, encoding="utf-8").read()
            txt = txt.replace("TITLE", name)
            open(layout_path, "w", encoding="utf-8").write(txt)

        # Activityへ setContentView 追記
        src = src.replace(
            "super.onCreate(savedInstanceState);",
            f"""super.onCreate(savedInstanceState);
        setContentView(R.layout.{layout_name.replace('.xml','')});"""
        )

        open(ap, "w", encoding="utf-8").write(src)

print("OK: Activities wired to XML")
