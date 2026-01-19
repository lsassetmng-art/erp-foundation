#!/data/data/com.termux/files/usr/bin/bash
set -e

############################################
# FOUNDATION UI GENERATE (Android 正道)
# - Fragment 自動生成
# - inputs.schema.yaml
# - XML 自動生成
# - ViewModel.executeSafe
# cd非依存 / Termux対応
############################################

# --- ルート検出 ---
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== FOUNDATION UI GENERATE START ==="

# --- ディレクトリ ---
mkdir -p spec tools \
  app/src/main/java/app/ui/fragment \
  app/src/main/java/app/ui/viewmodel \
  app/src/main/res/layout \
  app/src/main/res/navigation

############################################
# 1️⃣ inputs.schema.yaml（完全テンプレ）
############################################
cat << 'YAML' > spec/inputs.schema.yaml
inputs:
  CreateOrder:
    fields:
      orderNo:
        type: string
        required: true
        maxLength: 20
      amount:
        type: number
        required: true

  Login:
    fields:
      email:
        type: string
        required: true
      password:
        type: string
        required: true
YAML
echo "OK: spec/inputs.schema.yaml"

############################################
# 2️⃣ ViewModel.executeSafe 自動生成
############################################
cat << 'PY' > tools/generate_viewmodel_execute_safe.py
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"
VM_DIR.mkdir(parents=True, exist_ok=True)

code = """package app.ui.viewmodel;

public abstract class BaseViewModel {

    protected <T> void executeSafe(Callable<T> action) {
        try {
            action.call();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public interface Callable<T> {
        T call() throws Exception;
    }
}
"""
(Base := VM_DIR / "BaseViewModel.java").write_text(code, encoding="utf-8")
print("OK: ViewModel executeSafe generated")
PY

python3 tools/generate_viewmodel_execute_safe.py

############################################
# 3️⃣ Fragment + XML 自動生成
############################################
cat << 'PY' > tools/generate_fragments_and_xml.py
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

fragments = [
    ("CreateOrder", ["orderNo", "amount"]),
    ("Login", ["email", "password"])
]

for name, fields in fragments:
    # Fragment
    fdir = ROOT / "app/src/main/java/app/ui/fragment"
    fdir.mkdir(parents=True, exist_ok=True)
    f = fdir / f"{name}Fragment.java"
    f.write_text(f"""package app.ui.fragment;

import androidx.fragment.app.Fragment;

public class {name}Fragment extends Fragment {{
}}
""", encoding="utf-8")

    # XML
    ldir = ROOT / "app/src/main/res/layout"
    ldir.mkdir(parents=True, exist_ok=True)
    xml = ldir / f"fragment_{name.lower()}.xml"

    fields_xml = "\\n".join([
        f'<EditText android:id="@+id/input_{fld}" android:hint="{fld}" />'
        for fld in fields
    ])

    xml.write_text(f"""<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
{fields_xml}
</LinearLayout>
""", encoding="utf-8")

print("OK: Fragments + XML generated")
PY

python3 tools/generate_fragments_and_xml.py

############################################
# 4️⃣ nav_graph.xml 自動生成
############################################
cat << 'XML' > app/src/main/res/navigation/nav_graph.xml
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/nav_graph"
    app:startDestination="@id/loginFragment">

    <fragment
        android:id="@+id/loginFragment"
        android:name="app.ui.fragment.LoginFragment" />

    <fragment
        android:id="@+id/createOrderFragment"
        android:name="app.ui.fragment.CreateOrderFragment" />

</navigation>
XML

echo "OK: nav_graph.xml"

echo "=== FOUNDATION UI GENERATE DONE ==="
echo "Check:"
echo " - spec/inputs.schema.yaml"
echo " - app/ui/fragment/"
echo " - app/ui/viewmodel/"
echo " - res/layout/"
echo " - res/navigation/nav_graph.xml"
