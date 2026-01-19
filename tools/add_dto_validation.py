import os, re

DTO_ROOT = "app/src/main/java/app/dto"

for root, _, files in os.walk(DTO_ROOT):
    for f in files:
        if not f.endswith("Input.java"):
            continue
        p = os.path.join(root, f)
        src = open(p, encoding="utf-8").read()

        if "validate()" in src:
            continue

        inject = """
    public void validate() {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Input value is required");
        }
    }
"""
        src = src.replace("}", inject + "\n}", 1)
        open(p, "w", encoding="utf-8").write(src)

print("OK: DTO validations added")
