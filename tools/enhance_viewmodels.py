import os

VM_ROOT = "app/src/main/java/app/viewmodel"

for root, _, files in os.walk(VM_ROOT):
    for f in files:
        if not f.endswith("ViewModel.java"):
            continue

        path = os.path.join(root, f)
        with open(path) as fp:
            content = fp.read()

        if "// BINDING READY" in content:
            continue

        content = content.replace(
            "{",
            "{\n    // BINDING READY\n    // TODO: expose execute() via LiveData / StateFlow\n",
            1
        )

        with open(path, "w") as out:
            out.write(content)

print("OK: ViewModels enhanced")
