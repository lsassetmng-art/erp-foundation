import os
import re

VM_ROOT = "app/src/main/java/app/viewmodel"

for root, _, files in os.walk(VM_ROOT):
    for f in files:
        if not f.endswith("ViewModel.java"):
            continue

        vp = os.path.join(root, f)
        src = open(vp, encoding="utf-8").read()

        if "execute(" in src:
            continue  # already wired

        # 推測
        name = f.replace("ViewModel.java", "")
        domain = os.path.basename(root)
        input_dto = f"{name}Input"
        usecase = f"{name}UseCase"

        # import 追加
        src = src.replace(
            "import app.usecase.",
            f"import app.dto.{domain}.{input_dto};\nimport app.usecase."
        )

        inject = f"""
    public Object execute({input_dto} input) throws Exception {{
        return useCase.execute(input);
    }}
"""

        src = src.replace("}", inject + "\n}", 1)
        open(vp, "w", encoding="utf-8").write(src)

print("OK: ViewModel.execute wired")
