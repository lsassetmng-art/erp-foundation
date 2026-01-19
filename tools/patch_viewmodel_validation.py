#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"

for vm in VM_DIR.glob("*ViewModel.java"):
    text = vm.read_text(encoding="utf-8")

    if "Map<String, String>" in text:
        continue

    insert = """
import java.util.Map;
import java.util.HashMap;
import androidx.lifecycle.MutableLiveData;
"""

    text = text.replace("import androidx.lifecycle.ViewModel;", 
                         "import androidx.lifecycle.ViewModel;" + insert)

    text = re.sub(
        r"public final MutableLiveData<String> error = new MutableLiveData<>\\(\\);",
        "public final MutableLiveData<Map<String,String>> errors = new MutableLiveData<>();",
        text
    )

    text = re.sub(
        r"catch \\(Exception e\\) \\{[\\s\\S]*?\\}",
        """catch (Exception e) {
            Map<String,String> map = new HashMap<>();
            map.put("global", e.getMessage());
            errors.postValue(map);
        }""",
        text
    )

    vm.write_text(text, encoding="utf-8")
    print(f"OK: patched {vm.name}")
