#!/usr/bin/env python3
import os, yaml

ROOT = os.path.expanduser("~/erp-foundation")
JAVA_BASE = os.path.join(ROOT, "app/src/main/java")
TEST_BASE = os.path.join(JAVA_BASE, "test")

def ensure(p):
    os.makedirs(p, exist_ok=True)

def mock_value(t):
    if t == "string":
        return "\"TEST\""
    if t == "integer":
        return "1"
    if t == "number":
        return "1.0"
    if t == "boolean":
        return "true"
    return "null"

with open(os.path.join(ROOT, "spec/usecases.schema.yaml"), "r") as f:
    spec = yaml.safe_load(f)

for uc in spec.get("usecases", []):
    domain = uc["domain"]
    name = uc["name"]

    in_props = uc.get("input_schema", {}).get("properties", {})
    out_props = uc.get("output_schema", {}).get("properties", {})

    pkg = f"test.{domain}"
    test_dir = os.path.join(TEST_BASE, domain)
    ensure(test_dir)

    with open(os.path.join(test_dir, f"{name}RpcTest.java"), "w") as w:
        w.write(f"""package {pkg};

import org.json.JSONObject;
import app.usecase.{domain}.{name}Input;
import app.usecase.{domain}.{name}Result;

public final class {name}RpcTest {{

    public static void main(String[] args) {{
        // ---- Input mock ----
        {name}Input input = new {name}Input(
""")
        w.write(",\n".join([f"            {mock_value(v.get('type'))}" for v in in_props.values()]))
        w.write("""
        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();
""")
        for k, v in out_props.items():
            w.write(f"        out.put(\"{k}\", {mock_value(v.get('type'))});\n")

        w.write(f"""
        {name}Result result = {name}Result.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: {name}RpcTest");
    }}
}}
""")

print("OK: RPC mock tests generated")
