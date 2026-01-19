#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
USECASE_DIR = ROOT / "app/src/main/java/app/usecase"
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"
FRAG_DIR = ROOT / "app/src/main/java/app/ui/fragment"

VM_DIR.mkdir(parents=True, exist_ok=True)
FRAG_DIR.mkdir(parents=True, exist_ok=True)

for uc in USECASE_DIR.rglob("*UseCase.java"):
    name = uc.stem.replace("UseCase", "")
    domain = uc.parent.name

    vm = VM_DIR / f"{name}ViewModel.java"
    frag = FRAG_DIR / f"{name}Fragment.java"

    if not vm.exists():
        vm.write_text(f"""package app.ui.viewmodel;

import androidx.lifecycle.ViewModel;
import androidx.lifecycle.MutableLiveData;
import app.usecase.{domain}.{name}UseCase;

public final class {name}ViewModel extends ViewModel {{

    private final {name}UseCase useCase;
    public final MutableLiveData<String> error = new MutableLiveData<>();

    public {name}ViewModel({name}UseCase useCase) {{
        this.useCase = useCase;
    }}

    public void executeSafe(Object input) {{
        try {{
            useCase.execute(input);
        }} catch (Exception e) {{
            error.postValue(e.getMessage());
        }}
    }}
}}
""", encoding="utf-8")

    if not frag.exists():
        frag.write_text(f"""package app.ui.fragment;

import androidx.fragment.app.Fragment;
import app.ui.viewmodel.{name}ViewModel;

public final class {name}Fragment extends Fragment {{
    private {name}ViewModel vm;
}}
""", encoding="utf-8")

print("OK: UI binding generated")
