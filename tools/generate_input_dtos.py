import os
import re

USECASE_ROOT = "app/src/main/java/app/usecase"
DTO_ROOT = "app/src/main/java/app/dto"

os.makedirs(DTO_ROOT, exist_ok=True)

for root, _, files in os.walk(USECASE_ROOT):
    for f in files:
        if not f.endswith("UseCase.java"):
            continue

        name = f.replace("UseCase.java", "")
        dto = name + "Input"
        domain = os.path.basename(root)

        dto_dir = os.path.join(DTO_ROOT, domain)
        os.makedirs(dto_dir, exist_ok=True)

        dto_path = os.path.join(dto_dir, f"{dto}.java")
        if os.path.exists(dto_path):
            continue

        with open(dto_path, "w", encoding="utf-8") as out:
            out.write(f"""package app.dto.{domain};

public final class {dto} {{

    // TODO: フィールドは後で拡張（今は共通1項目）
    private String value;

    public String getValue() {{
        return value;
    }}

    public void setValue(String value) {{
        this.value = value;
    }}
}}
""")

print("OK: Input DTOs generated")
