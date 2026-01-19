import os

ACT = "app/src/main/java/app/activity"

for root, _, files in os.walk(ACT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue
        p = os.path.join(root, f)
        src = open(p, encoding="utf-8").read()

        if "AlertDialog" in src:
            continue

        src = src.replace(
            "import android.widget.Toast;",
            "import androidx.appcompat.app.AlertDialog;"
        ).replace(
            "Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();",
            "new AlertDialog.Builder(this).setMessage(e.getMessage()).setPositiveButton(\"OK\", null).show();"
        )

        open(p, "w", encoding="utf-8").write(src)

print("OK: Error UI switched to Dialog")
