#!/usr/bin/env python3
import os, yaml

ROOT = os.path.expanduser("~/erp-foundation")
JAVA_BASE = os.path.join(ROOT, "app/src/main/java")
UC_BASE = os.path.join(JAVA_BASE, "app/usecase")
REPO_BASE = os.path.join(JAVA_BASE, "foundation/repository")

def ensure(p):
    os.makedirs(p, exist_ok=True)

def java_type(prop):
    t = prop.get("type")
    if t == "string":
        return "String"
    if t == "number":
        return "Double"
    if t == "integer":
        return "Integer"
    if t == "boolean":
        return "Boolean"
    return "String"

with open(os.path.join(ROOT, "spec/usecases.schema.yaml"), "r", encoding="utf-8") as f:
    spec = yaml.safe_load(f)

for uc in spec.get("usecases", []):
    domain = uc["domain"]
    name = uc["name"]
    flow = uc.get("flow", [])
    rpc = uc["rpc"]

    pkg_uc = f"app.usecase.{domain}"
    pkg_repo = "foundation.repository"

    uc_dir = os.path.join(UC_BASE, domain)
    ensure(uc_dir)
    ensure(REPO_BASE)

    # ---------- Input DTO ----------
    in_schema = uc.get("input_schema", {})
    in_props = in_schema.get("properties", {})
    with open(os.path.join(uc_dir, f"{name}Input.java"), "w") as w:
        w.write(f"""package {pkg_uc};

import org.json.JSONObject;

public final class {name}Input {{
""")
        for k, v in in_props.items():
            w.write(f"  public final {java_type(v)} {k};\n")

        w.write(f"""
  public {name}Input({", ".join([f"{java_type(v)} {k}" for k,v in in_props.items()])}) {{
""")
        for k in in_props.keys():
            w.write(f"    this.{k} = {k};\n")
        w.write("""  }

  public JSONObject toJson() {
    JSONObject o = new JSONObject();
""")
        for k in in_props.keys():
            w.write(f"    if ({k} != null) o.put(\"{k}\", {k});\n")
        w.write("""    return o;
  }

  public static """ + name + """Input fromJson(JSONObject o) {
    return new """ + name + """Input(
""")
        w.write(",\n".join([f"      o.opt{java_type(v)}(\"{k}\")" for k,v in in_props.items()]))
        w.write("""
    );
  }
}
""")

    # ---------- Output DTO ----------
    out_schema = uc.get("output_schema", {})
    out_props = out_schema.get("properties", {})
    with open(os.path.join(uc_dir, f"{name}Result.java"), "w") as w:
        w.write(f"""package {pkg_uc};

import org.json.JSONObject;

public final class {name}Result {{
""")
        for k, v in out_props.items():
            w.write(f"  public {java_type(v)} {k};\n")

        w.write("""
  public static """ + name + """Result fromJson(JSONObject o) {
    """ + name + """Result r = new """ + name + """Result();
""")
        for k in out_props.keys():
            w.write(f"    r.{k} = o.opt{java_type(out_props[k])}(\"{k}\");\n")
        w.write("""    return r;
  }

  public JSONObject toJson() {
    JSONObject o = new JSONObject();
""")
        for k in out_props.keys():
            w.write(f"    o.put(\"{k}\", {k});\n")
        w.write("""    return o;
  }
}
""")

    # ---------- Repository IF ----------
    with open(os.path.join(uc_dir, f"{name}Repository.java"), "w") as w:
        w.write(f"""package {pkg_uc};

public interface {name}Repository {{
    {name}Result call({name}Input input) throws Exception;
}}
""")

    # ---------- UseCase ----------
    with open(os.path.join(uc_dir, f"{name}UseCase.java"), "w") as w:
        w.write(f"""package {pkg_uc};

/**
 * {name}UseCase
 *
 * Flow: {", ".join(flow)}
 * Input: {name}Input
 * Output: {name}Result
 */
public final class {name}UseCase {{

    private final {name}Repository repository;

    public {name}UseCase({name}Repository repository) {{
        this.repository = repository;
    }}

    public {name}Result execute({name}Input input) throws Exception {{
        return repository.call(input);
    }}
}}
""")

    # ---------- RPC Repository ----------
    action = list(rpc.values())[0]
    with open(os.path.join(REPO_BASE, f"Rpc{name}Repository.java"), "w") as w:
        w.write(f"""package {pkg_repo};

import org.json.JSONObject;
import {pkg_uc}.{name}Repository;
import {pkg_uc}.{name}Input;
import {pkg_uc}.{name}Result;

public final class Rpc{name}Repository
        extends RpcRepository
        implements {name}Repository {{

    @Override
    public {name}Result call({name}Input input) throws Exception {{
        JSONObject res = callRpc("{action}", input.toJson());
        return {name}Result.fromJson(res);
    }}
}}
""")

print("OK: UseCases + DTOs + JSON mappers generated")
