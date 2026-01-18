#!/usr/bin/env python3
import os, yaml

ROOT = os.path.expanduser("~/erp-foundation")
JAVA_BASE = os.path.join(ROOT, "app/src/main/java")
TEST_BASE = os.path.join(JAVA_BASE, "test")

def ensure(p):
    os.makedirs(p, exist_ok=True)

def wrong_value(t):
    if t == "string":
        return "1"
    if t == "integer":
        return "\"STR\""
    if t == "number":
        return "\"STR\""
    if t == "boolean":
        return "\"STR\""
    return "null"

with open(os.path.join(ROOT, "spec/usecases.schema.yaml"), "r") as f:
    spec = yaml.safe_load(f)

for uc in spec.get("usecases", []):
    domain = uc["domain"]
    name = uc["name"]
    out_schema = uc.get("output_schema", {})
    props = out_schema.get("properties", {})
    required = out_schema.get("required", [])

    pkg = f"test.{domain}"
    test_dir = os.path.join(TEST_BASE, domain)
    ensure(test_dir)

    with open(os.path.join(test_dir, f"{name}RpcNegativeTest.java"), "w") as w:
        w.write(f"""package {pkg};

import org.json.JSONObject;
import validation.{domain}.{name}SchemaValidator;

public final class {name}RpcNegativeTest {{

    public static void main(String[] args) {{
        // ---- Missing required field tests ----
""")
        for r in required:
            w.write(f"""
        try {{
            JSONObject o = new JSONObject();
            // missing: {r}
            {name}SchemaValidator.validate(o);
            throw new RuntimeException("FAIL: missing {r} not detected");
        }} catch (IllegalArgumentException ok) {{
            System.out.println("OK: missing {r} detected");
        }}
""")

        w.write("""
        // ---- Invalid type tests ----
""")
        for k, v in props.items():
            t = v.get("type")
            w.write(f"""
        try {{
            JSONObject o = new JSONObject();
            o.put("{k}", {wrong_value(t)});
            {name}SchemaValidator.validate(o);
            throw new RuntimeException("FAIL: invalid type for {k} not detected");
        }} catch (IllegalArgumentException ok) {{
            System.out.println("OK: invalid type for {k} detected");
        }}
""")

        w.write("""
        System.out.println("OK: all negative tests passed");
    }
}
""")

print("OK: RPC negative tests generated")
