import os, re

ACT_ROOT = "app/src/main/java/app/activity"
OUT_ROOT = "app/src/main/java/app/ui/compose"

os.makedirs(OUT_ROOT, exist_ok=True)

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue
        name = f.replace("Activity.java", "")  # e.g. CreateOrder
        # domain = folder name under activity
        parts = root.split(os.sep)
        domain = parts[-1] if parts[-1] != "activity" else "core"

        out_dir = os.path.join(OUT_ROOT, domain)
        os.makedirs(out_dir, exist_ok=True)

        out_path = os.path.join(out_dir, f"{name}Screen.kt")
        if os.path.exists(out_path):
            continue

        with open(out_path, "w", encoding="utf-8") as out:
            out.write(f"""package app.ui.compose.{domain}

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text

@Composable
fun {name}Screen() {{
    Text(text = "{domain}/{name}")
}}
""")

print("OK: Compose screens generated")
