from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "spec/inputs.schema.yaml"
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"
VM_DIR.mkdir(parents=True, exist_ok=True)

spec = yaml.safe_load(SPEC.read_text())

# BaseViewModel
base = """package app.ui.viewmodel;

public abstract class BaseViewModel {

    protected void executeSafe(Runnable action) {
        try {
            action.run();
        } catch (IllegalArgumentException e) {
            onValidationError(e.getMessage());
        } catch (Exception e) {
            onSystemError(e);
        }
    }

    protected abstract void onValidationError(String message);
    protected abstract void onSystemError(Exception e);
}
"""
(VM_DIR / "BaseViewModel.java").write_text(base, encoding="utf-8")

for s in spec["screens"]:
    name = s["name"]
    fields = s["fields"]

    code = [f"package app.ui.viewmodel;",
            "",
            f"public class {name}ViewModel extends BaseViewModel {{",
            "",
            "    public void submit(Input input) {",
            "        executeSafe(() -> {"]

    for fname, rule in fields.items():
        if rule.get("required"):
            code.append(f'            if (input.{fname} == null || input.{fname}.toString().isEmpty())')
            code.append(f'                throw new IllegalArgumentException("{fname} is required");')

        if rule.get("minLength"):
            code.append(f'            if (input.{fname}.length() < {rule["minLength"]})')
            code.append(f'                throw new IllegalArgumentException("{fname} too short");')

        if rule.get("maxLength"):
            code.append(f'            if (input.{fname}.length() > {rule["maxLength"]})')
            code.append(f'                throw new IllegalArgumentException("{fname} too long");')

        if rule.get("min") is not None:
            code.append(f'            if (input.{fname} < {rule["min"]})')
            code.append(f'                throw new IllegalArgumentException("{fname} too small");')

    code += [
        "        });",
        "    }",
        "",
        "    public static class Input {"
    ]

    for fname, rule in fields.items():
        jtype = "String" if rule["type"] == "string" else "Integer"
        code.append(f"        public {jtype} {fname};")

    code += ["    }", "}"]

    (VM_DIR / f"{name}ViewModel.java").write_text("\n".join(code), encoding="utf-8")

print("OK: ViewModels generated")
