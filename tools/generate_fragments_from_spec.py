from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "spec/usecases.schema.yaml"
FRAG = ROOT / "app/src/main/java/app/ui/fragment"

if not SPEC.exists():
    print("SKIP: usecases.schema.yaml not found")
    exit(0)

data = yaml.safe_load(SPEC.read_text())
for uc in data.get("usecases", []):
    domain = uc["domain"]
    name = uc["name"]

    d = FRAG / domain
    d.mkdir(parents=True, exist_ok=True)

    f = d / f"{name}Fragment.java"
    if f.exists():
        continue

    f.write_text(f"""
package app.ui.fragment.{domain};

import androidx.fragment.app.Fragment;
import app.R;

public class {name}Fragment extends Fragment {{
}}
""".strip(), encoding="utf-8")

    print("OK: Fragment", f.relative_to(ROOT))
