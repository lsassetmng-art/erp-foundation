#!/usr/bin/env python3
import os, yaml

ROOT = os.path.expanduser("~/erp-foundation")
JAVA_BASE = os.path.join(ROOT, "app/src/main/java")
VAL_BASE = os.path.join(JAVA_BASE, "validation")

def ensure(p):
    os.makedirs(p, exist_ok=True)

def java_check(k, t):
    if t == "string":
        return f'o.has("{k}") && o.get("{k}") instanceof String'
    if t == "integer":
        return f'o.has("{k}") && o.get("{k}") instanceof Integer'
    if t == "number":
        return f'o.has("{k}") && o.get("{k}") instanceof Number'
    if t == "boolean":
        return f'o.has("{k}") && o.get("{k}") instanceof Boolean'
    return f'o.has("{k}")'

with open(os.path.join(ROOT, "spec/usecases.schema.yaml"), "r") as f:
    spec = yaml.safe_load(f)

for uc in spec.get("usecases", []):
    domain = uc["domain"]
    name = uc["name"]

    out_schema = uc.get("output_schema", {})
    props = out_schema.get("properties", {})
    required = out_schema.get("required", [])

    pkg = f"validation.{domain}"
    out_dir = os.path.join(VAL_BASE, domain)
    ensure(out_dir)

    with open(os.path.join(out_dir, f"{name}SchemaValidator.java"), "w") as w:
        w.write(f"""package {pkg};

import org.json.JSONObject;

public final class {name}SchemaValidator {{

    public static void validate(JSONObject o) {{
""")
        for k in required:
            w.write(f"""
        if (!o.has("{k}")) {{
            throw new IllegalArgumentException("Missing required field: {k}");
        }}
""")
        for k, v in props.items():
            t = v.get("type")
            w.write(f"""
        if (o.has("{k}") && !({java_check(k, t)})) {{
            throw new IllegalArgumentException("Invalid type for field: {k}");
        }}
""")
        w.write("""
    }
}
""")

print("OK: RPC schema validators generated")
