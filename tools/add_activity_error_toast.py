import os

ACT_ROOT = "app/src/main/java/app/activity"

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue
        p = os.path.join(root, f)
        src = open(p, encoding="utf-8").read()

        if "Toast.makeText" in src:
            continue

        if "import android.widget.Toast;" not in src:
            src = src.replace(
                "import android.widget.EditText;\n",
                "import android.widget.EditText;\nimport android.widget.Toast;\n"
            )

        src = src.replace(
            "vm.execute(input);",
            """try {
                    vm.executeSafe(input);
                } catch (IllegalArgumentException e) {
                    Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
                }"""
        )

        open(p, "w", encoding="utf-8").write(src)

print("OK: Activity Toast error handling added")
