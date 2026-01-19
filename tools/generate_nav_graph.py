import os

ACT_ROOT = "app/src/main/java/app/activity"
OUT = "docs/navigation.md"

lines = ["# Navigation Graph", ""]

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if f.endswith("Activity.java"):
            lines.append(f"- {f.replace('.java','')}")

with open(OUT, "w") as out:
    out.write("\n".join(lines))

print("OK: navigation graph generated")
