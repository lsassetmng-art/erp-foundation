import os
import re

ACT_ROOT = "app/src/main/java/app/activity"

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue

        ap = os.path.join(root, f)
        src = open(ap, encoding="utf-8").read()

        if "ViewModel.execute" in src:
            continue

        base = f.replace("Activity.java", "")
        domain = os.path.basename(root)
        vm = base + "ViewModel"
        dto = base + "Input"

        # import
        if f"import app.viewmodel.{domain}.{vm};" not in src:
            src = src.replace(
                "import android.widget.EditText;\n",
                f"import android.widget.EditText;\nimport app.viewmodel.{domain}.{vm};\nimport app.dto.{domain}.{dto};\n"
            )

        # 実行部置換
        src = src.replace(
            "// TODO: ViewModel.execute(input)",
            f"""{vm} vm = new {vm}(null);
                    vm.execute(input);"""
        )

        open(ap, "w", encoding="utf-8").write(src)

print("OK: Activity execute TODO resolved")
