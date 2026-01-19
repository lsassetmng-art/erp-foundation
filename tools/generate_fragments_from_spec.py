#!/usr/bin/env python3
"""
generate_fragments_from_spec.py

- usecases.schema.yaml から Fragment を自動生成
- HostActivity / nav_graph は既存前提（存在しなければスキップ）
- XML は後続フェーズで生成（ここでは Java のみ）
"""

from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "spec/usecases.schema.yaml"
FRAG_ROOT = ROOT / "app/src/main/java/app/ui/fragment"

if not SPEC.exists():
    print("SKIP: usecases.schema.yaml not found")
    exit(0)

data = yaml.safe_load(SPEC.read_text(encoding="utf-8"))
usecases = data.get("usecases", [])

for uc in usecases:
    domain = uc["domain"]
    name = uc["name"]
    class_name = f"{name}Fragment"

    pkg_dir = FRAG_ROOT / domain
    pkg_dir.mkdir(parents=True, exist_ok=True)

    file = pkg_dir / f"{class_name}.java"
    if file.exists():
        continue

    code = f"""package app.ui.fragment.{domain};

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import app.R;

public class {class_name} extends Fragment {{

    @Nullable
    @Override
    public View onCreateView(
            @NonNull LayoutInflater inflater,
            @Nullable ViewGroup container,
            @Nullable Bundle savedInstanceState
    ) {{
        return inflater.inflate(R.layout.fragment_{name.lower()}, container, false);
    }}
}}
"""
    file.write_text(code, encoding="utf-8")
    print(f"OK: generated {file.relative_to(ROOT)}")

print("OK: Fragment generation complete")
