#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
VAL = ROOT / "spec/validation.schema.yaml"
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"

if not VAL.exists():
    raise SystemExit(f"ERROR: {VAL} not found. Run generate_validation_schema.py first.")

# 超軽量YAML（このプロジェクト用に限定パース）
def parse_yaml(path: Path):
    data = {}
    cur_cls = None
    cur_field = None
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if re.match(r'^version:\s*\d+', line):
            continue
        m = re.match(r'^rules:\s*$', line)
        if m:
            continue
        m = re.match(r'^\s{2}([A-Za-z0-9_]+):\s*$', line)
        if m:
            cur_cls = m.group(1)
            data.setdefault(cur_cls, {})
            cur_field = None
            continue
        m = re.match(r'^\s{4}([a-zA-Z_][a-zA-Z0-9_]*):\s*$', line)
        if m and cur_cls:
            cur_field = m.group(1)
            data[cur_cls].setdefault(cur_field, {})
            continue
        m = re.match(r'^\s{6}([A-Za-z0-9_]+):\s*(.+)\s*$', line)
        if m and cur_cls and cur_field:
            k = m.group(1)
            v = m.group(2).strip()
            if v in ("true","false"):
                vv = (v == "true")
            elif re.match(r'^\d+(\.\d+)?$', v):
                vv = int(v) if v.isdigit() else float(v)
            else:
                vv = v.strip('"')
            data[cur_cls][cur_field][k] = vv
    return data

rules = parse_yaml(VAL)

def ensure_imports(text: str):
    if "java.util.Map" in text:
        return text
    ins = "\nimport java.util.Map;\nimport java.util.HashMap;\nimport androidx.lifecycle.MutableLiveData;\n"
    # ViewModel import の直後に差し込む
    text = text.replace("import androidx.lifecycle.ViewModel;", "import androidx.lifecycle.ViewModel;" + ins)
    return text

def ensure_errors_livedata(text: str):
    if "MutableLiveData<Map<String,String>> errors" in text:
        return text
    # 既存 error:String があれば置換、なければ追加
    if "MutableLiveData<String> error" in text:
        text = re.sub(r'public\s+final\s+MutableLiveData<String>\s+error\s*=\s*new\s+MutableLiveData<>\(\);\s*',
                      'public final MutableLiveData<Map<String,String>> errors = new MutableLiveData<>();\n',
                      text)
    else:
        # class の先頭付近に追加
        text = re.sub(r'(public\s+final\s+class\s+[A-Za-z0-9_]+\s*\{\s*)',
                      r'\1\n  public final MutableLiveData<Map<String,String>> errors = new MutableLiveData<>();\n',
                      text, count=1)
    return text

def add_validator_method(text: str, vm_name: str):
    if "validateAndCollectErrors" in text:
        return text
    # executeSafe がある前提、なければ何もしない（壊さない）
    if "executeSafe" not in text:
        return text
    # Inputクラス名推定: XxxViewModel -> XxxInput を優先
    base = vm_name.replace("ViewModel","")
    candidate_inputs = [base + "Input"]
    # 生成済みUseCase由来だと CreateOrderViewModel などがあるため、Inputは CreateOrderInput
    # それ以外は validation.schema.yaml 側にあれば使う
    input_cls = None
    for c in candidate_inputs:
        if c in rules:
            input_cls = c
            break
    if input_cls is None:
        # rulesの中で最も近いもの（先頭一致）を探す
        for k in rules.keys():
            if k.startswith(base):
                input_cls = k
                break
    if input_cls is None:
        return text

    field_rules = rules.get(input_cls, {})

    # Javaコード生成（文字列長とrequiredだけ確実に）
    checks = []
    for field, r in field_rules.items():
        req = r.get("required", False)
        minLen = r.get("minLen", 0)
        maxLen = r.get("maxLen", None)
        # input.<field> へのアクセスは public field or getter の可能性があるが、壊さないため reflection に寄せる
        # ただし既存DTOが public final field なら直接が最速。ここは安全優先で reflection。
        checks.append(f"""
      // {field}
      Object v_{field} = null;
      try {{
        java.lang.reflect.Field f = input.getClass().getDeclaredField("{field}");
        f.setAccessible(true);
        v_{field} = f.get(input);
      }} catch (Exception ignore) {{}}
      if (v_{field} == null) {{
        // try getter
        try {{
          String m = "get" + "{field}"[0].toUpperCase() + "{field}"[1:];
          v_{field} = input.getClass().getMethod(m).invoke(input);
        }} catch (Exception ignore) {{}}
      }}
""")
        if req:
            checks.append(f"""
      if (v_{field} == null) {{
        map.put("{field}", "required");
      }}""")
        # String length
        if maxLen is not None or minLen:
            checks.append(f"""
      if (v_{field} instanceof String) {{
        String s = (String) v_{field};
        int n = s.length();
        int minL = {int(minLen)};
        int maxL = {int(maxLen) if maxLen is not None else 2147483647};
        if (minL > 0 && n < minL) map.put("{field}", "minLen:" + minL);
        if (maxL < 2147483647 && n > maxL) map.put("{field}", "maxLen:" + maxL);
      }}""")

    method = f"""
  private Map<String,String> validateAndCollectErrors(Object input) {{
    Map<String,String> map = new HashMap<>();
{''.join(checks)}
    return map;
  }}
"""

    # executeSafe内で呼ぶ（壊さない：tryで包む）
    if "validateAndCollectErrors" not in text:
        # executeSafe の先頭付近に挿入
        text = re.sub(r'(public\s+void\s+executeSafe\s*\([^)]*\)\s*\{\s*)',
                      r'\1\n    try {\n      Map<String,String> vmap = validateAndCollectErrors(input);\n      if (vmap != null && !vmap.isEmpty()) { errors.postValue(vmap); return; }\n    } catch (Exception ignore) {}\n',
                      text, count=1)

    # class末尾手前に追加
    text = re.sub(r'\n\}\s*$', method + "\n}\n", text, count=1)
    return text

patched = 0
for vm in VM_DIR.glob("*ViewModel.java"):
    t = vm.read_text(encoding="utf-8", errors="ignore")
    t2 = ensure_imports(t)
    t2 = ensure_errors_livedata(t2)
    t2 = add_validator_method(t2, vm.name)
    if t2 != t:
        vm.write_text(t2, encoding="utf-8")
        patched += 1
        print(f"OK: patched {vm.relative_to(ROOT)}")

print(f"OK: ViewModel validation applied: {patched} file(s)")
