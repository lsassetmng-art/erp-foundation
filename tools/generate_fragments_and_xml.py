from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
SPEC = yaml.safe_load((ROOT / "spec/inputs.schema.yaml").read_text())

F_DIR = ROOT / "app/src/main/java/app/ui/fragment"
L_DIR = ROOT / "app/src/main/res/layout"
F_DIR.mkdir(parents=True, exist_ok=True)
L_DIR.mkdir(parents=True, exist_ok=True)

for s in SPEC["screens"]:
    name = s["name"]
    fields = s["fields"]

    # Fragment
    frag = f"""package app.ui.fragment;

import android.os.Bundle;
import android.view.*;
import android.widget.*;
import androidx.fragment.app.Fragment;
import app.R;
import app.ui.viewmodel.{name}ViewModel;

public class {name}Fragment extends Fragment {{

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle b) {{
        return inflater.inflate(R.layout.fragment_{name.lower()}, container, false);
    }}
}}
"""
    (F_DIR / f"{name}Fragment.java").write_text(frag, encoding="utf-8")

    # XML
    lines = []
    for f in fields:
        lines.append(f'<EditText android:id="@+id/input_{f}" android:hint="{f}" />')

    xml = f"""<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
{chr(10).join(lines)}
<Button android:id="@+id/btn_submit" android:text="Submit"/>
</LinearLayout>
"""
    (L_DIR / f"fragment_{name.lower()}.xml").write_text(xml, encoding="utf-8")

print("OK: Fragments + XML generated")
