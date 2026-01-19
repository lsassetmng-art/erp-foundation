from __future__ import annotations
from pathlib import Path
from typing import Any, Dict

def _load_with_pyyaml(text: str) -> Dict[str, Any]:
    import yaml  # type: ignore
    return yaml.safe_load(text) or {}

def _load_simple_yaml(text: str) -> Dict[str, Any]:
    # Minimal parser for our fixed schema only.
    # Supports: screens -> list of dicts -> name + fields -> field rules dict
    lines = [ln.rstrip("\n") for ln in text.splitlines()]
    def indent(s: str) -> int:
        return len(s) - len(s.lstrip(" "))

    data: Dict[str, Any] = {}
    i = 0
    def parse_value(v: str):
        v = v.strip()
        if v in ("true", "True"): return True
        if v in ("false", "False"): return False
        if v.isdigit(): return int(v)
        # allow negative int
        if v.startswith("-") and v[1:].isdigit(): return int(v)
        return v.strip('"').strip("'")

    # very small state machine
    while i < len(lines):
        ln = lines[i].strip()
        if not ln or ln.startswith("#"):
            i += 1
            continue
        if ln.startswith("screens:"):
            data["screens"] = []
            i += 1
            # parse list items
            while i < len(lines):
                raw = lines[i]
                if raw.strip() == "" or raw.lstrip().startswith("#"):
                    i += 1
                    continue
                if indent(raw) == 0:
                    break
                if raw.lstrip().startswith("- "):
                    item: Dict[str, Any] = {}
                    data["screens"].append(item)
                    # parse "- name: X"
                    rest = raw.lstrip()[2:].strip()
                    if ":" in rest:
                        k, v = rest.split(":", 1)
                        item[k.strip()] = parse_value(v)
                    i += 1
                    # parse item body
                    while i < len(lines):
                        raw2 = lines[i]
                        if raw2.strip() == "" or raw2.lstrip().startswith("#"):
                            i += 1
                            continue
                        if indent(raw2) <= 2:  # next list item or end
                            break
                        ln2 = raw2.strip()
                        if ln2.startswith("fields:"):
                            item["fields"] = {}
                            i += 1
                            # parse fields
                            while i < len(lines):
                                raw3 = lines[i]
                                if raw3.strip() == "" or raw3.lstrip().startswith("#"):
                                    i += 1
                                    continue
                                if indent(raw3) <= 4:
                                    break
                                # field name line: email:
                                if raw3.strip().endswith(":") and ":" not in raw3.strip()[:-1]:
                                    field_name = raw3.strip()[:-1].strip()
                                    item["fields"][field_name] = {}
                                    i += 1
                                    # parse rule lines under field
                                    while i < len(lines):
                                        raw4 = lines[i]
                                        if raw4.strip() == "" or raw4.lstrip().startswith("#"):
                                            i += 1
                                            continue
                                        if indent(raw4) <= 6:
                                            break
                                        k4, v4 = raw4.strip().split(":", 1)
                                        item["fields"][field_name][k4.strip()] = parse_value(v4)
                                        i += 1
                                else:
                                    i += 1
                            continue
                        else:
                            # other top keys in item (unused)
                            if ":" in ln2:
                                k, v = ln2.split(":", 1)
                                item[k.strip()] = parse_value(v)
                            i += 1
                    continue
                else:
                    i += 1
            continue
        i += 1
    return data

def load_inputs_spec(root_dir: Path) -> Dict[str, Any]:
    spec = root_dir / "spec" / "inputs.schema.yaml"
    if not spec.exists():
        raise FileNotFoundError(f"spec not found: {spec}")
    text = spec.read_text(encoding="utf-8")
    try:
        return _load_with_pyyaml(text)
    except Exception:
        return _load_simple_yaml(text)
