import os
import re

USECASE_ROOT = "app/src/main/java/app/usecase"
VM_ROOT = "app/src/main/java/app/viewmodel"

for root, _, files in os.walk(USECASE_ROOT):
    for f in files:
        if not f.endswith("UseCase.java"):
            continue

        path = os.path.join(root, f)
        with open(path) as fp:
            content = fp.read()

        pkg = re.search(r'package (.*);', content).group(1)
        domain = pkg.split('.')[-1]
        name = f.replace("UseCase.java", "")

        vm_dir = os.path.join(VM_ROOT, domain)
        os.makedirs(vm_dir, exist_ok=True)

        vm_path = os.path.join(vm_dir, f"{name}ViewModel.java")
        if os.path.exists(vm_path):
            continue

        with open(vm_path, "w") as out:
            out.write(f"""package app.viewmodel.{domain};

import androidx.lifecycle.ViewModel;
import app.usecase.{domain}.{name}UseCase;

public final class {name}ViewModel extends ViewModel {{

    private final {name}UseCase useCase;

    public {name}ViewModel({name}UseCase useCase) {{
        this.useCase = useCase;
    }}

    // TODO: expose LiveData / StateFlow
}}
""")

print("OK: ViewModels generated")
