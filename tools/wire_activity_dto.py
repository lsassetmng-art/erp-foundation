import os
import re

ACT_ROOT = "app/src/main/java/app/activity"

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue

        ap = os.path.join(root, f)
        src = open(ap, encoding="utf-8").read()

        if "// XML-DTO-WIRED" in src:
            continue

        # imports
        if "import android.widget.EditText;" not in src:
            src = src.replace(
                "import android.widget.Button;\n",
                "import android.widget.Button;\nimport android.widget.EditText;\n"
            )

        # DTO名推測（CreateOrderActivity → CreateOrderInput）
        base = f.replace("Activity.java", "")
        dto = base + "Input"

        inject = f"""
        // XML-DTO-WIRED
        EditText et = findViewById(R.id.input_text);
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null && et != null) {{
            btn.setOnClickListener(v -> {{
                try {{
                    {dto} input = new {dto}();
                    input.setValue(et.getText().toString());
                    // TODO: ViewModel.execute(input)
                }} catch (Exception e) {{
                    e.printStackTrace();
                }}
            }});
        }}
"""

        src = src.replace("}", inject + "\n}", 1)
        open(ap, "w", encoding="utf-8").write(src)

print("OK: Activity → DTO binding added")
