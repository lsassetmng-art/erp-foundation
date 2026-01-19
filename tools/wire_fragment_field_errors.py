#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
FRAG_DIR = ROOT / "app/src/main/java/app/ui/fragment"

def ensure_helper(java_text: str):
    if "applyFieldErrors(" in java_text:
        return java_text
    helper = r"""
  // Apply field errors without hard dependency on Material TextInputLayout.
  private void applyFieldErrors(android.view.View root, java.util.Map<String,String> map) {
    if (root == null || map == null) return;
    for (java.util.Map.Entry<String,String> e : map.entrySet()) {
      String field = e.getKey();
      String msg = e.getValue();
      if (field == null) continue;
      if ("global".equals(field)) continue;

      int id = root.getResources().getIdentifier("input_" + field, "id", root.getContext().getPackageName());
      android.view.View v = (id != 0) ? root.findViewById(id) : null;

      // 1) Try TextInputLayout by walking up parent chain via reflection
      boolean applied = false;
      if (v != null) {
        android.view.View cur = v;
        for (int i = 0; i < 6 && cur != null; i++) {
          try {
            Class<?> til = Class.forName("com.google.android.material.textfield.TextInputLayout");
            if (til.isInstance(cur)) {
              til.getMethod("setError", CharSequence.class).invoke(cur, msg);
              applied = true;
              break;
            }
          } catch (Exception ignore) {}
          android.view.ViewParent p = cur.getParent();
          cur = (p instanceof android.view.View) ? (android.view.View) p : null;
        }
      }

      // 2) Fallback: EditText#setError
      if (!applied && v instanceof android.widget.EditText) {
        ((android.widget.EditText) v).setError(msg);
        applied = true;
      }

      // 3) If view not found, ignore safely
    }
  }
"""
    # class末尾手前に追加
    return re.sub(r'\n\}\s*$', "\n" + helper + "\n}\n", java_text, count=1)

def wire_observer(java_text: str):
    # 既に wiring 済みなら何もしない
    if "applyFieldErrors(root" in java_text:
        return java_text

    # onViewCreated を探して root を取得
    # 典型: public View onCreateView(...) { View root = ...; return root; }
    # または onViewCreated(View view, Bundle savedInstanceState)
    if "onViewCreated" in java_text:
        # onViewCreated の中に observer 追加（view を root として使う）
        java_text = re.sub(
            r'(public\s+void\s+onViewCreated\s*\(\s*android\.view\.View\s+view\s*,\s*android\.os\.Bundle\s+savedInstanceState\s*\)\s*\{\s*[\s\S]*?super\.onViewCreated\(\s*view\s*,\s*savedInstanceState\s*\)\s*;\s*)',
            r'\1\n    try {\n      if (viewModel != null && viewModel.errors != null) {\n        viewModel.errors.observe(getViewLifecycleOwner(), map -> applyFieldErrors(view, map));\n      }\n    } catch (Exception ignore) {}\n',
            java_text, count=1
        )
        return java_text

    # onViewCreated が無い場合は壊さない（スキップ）
    return java_text

patched = 0
for f in FRAG_DIR.glob("*Fragment.java"):
    t = f.read_text(encoding="utf-8", errors="ignore")
    t2 = ensure_helper(t)
    t2 = wire_observer(t2)
    if t2 != t:
        f.write_text(t2, encoding="utf-8")
        patched += 1
        print(f"OK: patched {f.relative_to(ROOT)}")

print(f"OK: Fragment field error wiring applied: {patched} file(s)")
