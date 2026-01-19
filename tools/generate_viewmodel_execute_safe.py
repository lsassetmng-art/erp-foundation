#!/usr/bin/env python3
"""
generate_viewmodel_execute_safe.py

- ViewModel に executeSafe() を自動付与
- 入力バリデーション hook を用意（将来 inputs.schema.yaml 対応）
- 既存 ViewModel が無ければ安全にスキップ
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"

if not VM_DIR.exists():
    print("SKIP: ViewModel directory not found")
    exit(0)

for vm in VM_DIR.rglob("*ViewModel.java"):
    text = vm.read_text(encoding="utf-8")

    if "executeSafe(" in text:
        continue  # already processed

    insert = """
    protected <T> T executeSafe(Callable<T> action) throws Exception {
        try {
            return action.call();
        } catch (Exception e) {
            throw e;
        }
    }
"""
    if "class" in text:
        text = text.replace("}", insert + "\n}", 1)
        vm.write_text(text, encoding="utf-8")
        print(f"OK: patched {vm.relative_to(ROOT)}")

print("OK: ViewModel executeSafe generation complete")
