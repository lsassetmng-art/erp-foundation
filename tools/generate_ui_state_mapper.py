#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"

for vm in VM_DIR.glob("*ViewModel.java"):
    text = vm.read_text(encoding="utf-8", errors="ignore")
    if "UiState" in text:
        continue

    insert = """
    // ===== UI State =====
    public static class UiState {
        public boolean success;
        public String message;
        public Object data;
    }

    private UiState mapRpcResult(Object rpcResult) {
        UiState s = new UiState();
        if (rpcResult == null) {
            s.success = false;
            s.message = "No response";
        } else {
            s.success = true;
            s.data = rpcResult;
        }
        return s;
    }
"""
    text = text.replace("}", insert + "\n}", 1)
    vm.write_text(text, encoding="utf-8")
    print(f"OK: UI State mapper added -> {vm.name}")

print("OK: RPC → UI State mapping ready")
