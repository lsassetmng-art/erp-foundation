import os, re

VM_ROOT = "app/src/main/java/app/viewmodel"

for root, _, files in os.walk(VM_ROOT):
    for f in files:
        if not f.endswith("ViewModel.java"):
            continue
        p = os.path.join(root, f)
        src = open(p, encoding="utf-8").read()

        if "executeSafe" in src:
            continue

        inject = """
    public Object executeSafe(Object input) throws Exception {
        try {
            // DTO validation
            try {
                input.getClass().getMethod("validate").invoke(input);
            } catch (NoSuchMethodException ignore) {}
            return execute(input);
        } catch (IllegalArgumentException e) {
            throw e;
        }
    }
"""
        src = src.replace("}", inject + "\n}", 1)
        open(p, "w", encoding="utf-8").write(src)

print("OK: ViewModel error handling added")
