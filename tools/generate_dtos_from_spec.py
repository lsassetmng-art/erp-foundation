import yaml, os

SPEC = yaml.safe_load(open("spec/inputs.schema.yaml", encoding="utf-8"))
OUT = "app/src/main/java/app/dto"

for uc, conf in SPEC["inputs"].items():
    for domain in os.listdir(OUT):
        path = os.path.join(OUT, domain, f"{uc}Input.java")
        if not os.path.exists(path):
            continue

        fields = conf["fields"]
        lines = [f"package app.dto.{domain};\n\npublic final class {uc}Input {{\n"]

        for f in fields:
            t = "String" if f["type"] == "string" else "int"
            lines.append(f"    private {t} {f['name']};\n")

        for f in fields:
            t = "String" if f["type"] == "string" else "int"
            n = f["name"]
            cap = n[0].upper()+n[1:]
            lines.append(f"    public {t} get{cap}() {{ return {n}; }}\n")
            lines.append(f"    public void set{cap}({t} {n}) {{ this.{n} = {n}; }}\n")

        lines.append("    public void validate() {\n")
        for f in fields:
            if f["required"]:
                n = f["name"]
                if f["type"] == "string":
                    lines.append(f"        if ({n} == null || {n}.trim().isEmpty()) throw new IllegalArgumentException(\"{n} required\");\n")
                else:
                    lines.append(f"        if ({n} <= 0) throw new IllegalArgumentException(\"{n} must be > 0\");\n")
        lines.append("    }\n}\n")

        open(path, "w", encoding="utf-8").write("".join(lines))

print("OK: DTOs generated from spec")
