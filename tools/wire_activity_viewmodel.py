import os, re

ACT_ROOT = "app/src/main/java/app/activity"

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue
        ap = os.path.join(root, f)
        src = open(ap, encoding="utf-8").read()

        if "// XML-VM-WIRED" in src:
            continue

        # 依存追加（安全にimport）
        if "import android.widget.Button;" not in src:
            src = src.replace("import android.os.Bundle;\n",
                              "import android.os.Bundle;\nimport android.widget.Button;\n")

        # onCreate末尾にリスナー追加（スタブ）
        inject = """
        // XML-VM-WIRED
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null) {
            btn.setOnClickListener(v -> {
                // TODO: ViewModel.execute(input) を呼ぶ
            });
        }
"""
        src = src.replace("}", inject + "\n}", 1)

        open(ap, "w", encoding="utf-8").write(src)

print("OK: Activities wired to ViewModel (stub)")
