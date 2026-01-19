import os, re, yaml, pathlib

SPEC = pathlib.Path("spec/inputs.schema.yaml")
ACT_ROOT = pathlib.Path("app/src/main/java/app/activity")

if not SPEC.exists():
    raise SystemExit("ERROR: spec/inputs.schema.yaml not found")

data = yaml.safe_load(SPEC.read_text(encoding="utf-8")) or {}
inputs = data.get("inputs") or {}

def cap(s):
    return s[:1].upper() + s[1:] if s else s

for usecase, conf in inputs.items():
    act_name = f"{usecase}Activity.java"
    fields = conf.get("fields") or []

    targets = []
    for root, _, files in os.walk(ACT_ROOT):
        if act_name in files:
            targets.append(pathlib.Path(root) / act_name)

    for ap in targets:
        src = ap.read_text(encoding="utf-8")

        domain = ap.parent.name
        dto = f"{usecase}Input"
        vm = f"{usecase}ViewModel"

        def add_import(line):
            nonlocal_src = src
            if line not in nonlocal_src:
                nonlocal_src = re.sub(
                    r"(package [^;]+;)",
                    r"\1\n" + line,
                    nonlocal_src,
                    count=1
                )
            return nonlocal_src

        # imports
        src = add_import("import android.widget.EditText;")
        src = add_import("import android.widget.Button;")
        src = add_import("import android.widget.Toast;")
        src = add_import(f"import app.dto.{domain}.{dto};")
        src = add_import(f"import app.viewmodel.{domain}.{vm};")

        lines = []
        lines.append("        // AUTO_BIND_FROM_SPEC")
        lines.append(f"        final {vm} vm = new {vm}(null);")
        lines.append("        Button btn = findViewById(R.id.btn_execute);")
        lines.append("        if (btn != null) {")
        lines.append("            btn.setOnClickListener(v -> {")
        lines.append("                try {")
        lines.append(f"                    {dto} input = new {dto}();")

        for f in fields:
            name = f["name"]
            ftype = f.get("type", "string")
            lines.append(f"                    EditText et_{name} = findViewById(R.id.input_{name});")
            if ftype in ("int", "integer", "number"):
                lines.append(f"                    int {name} = 0;")
                lines.append(f"                    if (et_{name} != null) {{")
                lines.append(f"                        String s = et_{name}.getText().toString().trim();")
                lines.append(f"                        {name} = s.isEmpty() ? 0 : Integer.parseInt(s);")
                lines.append("                    }")
                lines.append(f"                    input.set{cap(name)}({name});")
            else:
                lines.append(f"                    String {name} = et_{name} == null ? \"\" : et_{name}.getText().toString();")
                lines.append(f"                    input.set{cap(name)}({name});")

        lines.append("                    vm.executeSafe(input);")
        lines.append("                } catch (IllegalArgumentException e) {")
        lines.append("                    Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();")
        lines.append("                } catch (Exception e) {")
        lines.append("                    e.printStackTrace();")
        lines.append("                }")
        lines.append("            });")
        lines.append("        }")

        block = "\n".join(lines)

        if "// AUTO_BIND_FROM_SPEC" in src:
            src = re.sub(
                r"\s*// AUTO_BIND_FROM_SPEC(.|\n)*?\n\s*}\s*",
                "\n" + block + "\n    }\n",
                src,
                count=1
            )
        else:
            src = re.sub(
                r"(setContentView\([^\)]+\);\s*)",
                r"\1\n" + block + "\n",
                src,
                count=1
            )

        ap.write_text(src, encoding="utf-8")

print("OK: Activities wired from input spec")
