#!/usr/bin/env python3
import os, yaml, datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SPEC = os.path.join(ROOT, "spec", "inputs.schema.yaml")
OUT_DIR = os.path.join(ROOT, "app", "src", "main", "java", "app", "ui", "viewmodel")

def load():
    with open(SPEC, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def ensure_dir(p):
    os.makedirs(p, exist_ok=True)

def write(path, text):
    ensure_dir(os.path.dirname(path))
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)

def main():
    data = load()
    ensure_dir(OUT_DIR)

    base = """package app.ui.viewmodel;

public abstract class BaseViewModel {

    public interface UiCallbacks {
        void onValidationError(String fieldId, String message);
        void onSystemError(Exception e);
        void onSuccess();
    }

    protected final UiCallbacks ui;

    protected BaseViewModel(UiCallbacks ui) {
        this.ui = ui;
    }

    protected final void executeSafe(Runnable action) {
        try {
            action.run();
        } catch (IllegalArgumentException e) {
            // Validation error
            ui.onValidationError("unknown", e.getMessage());
        } catch (Exception e) {
            ui.onSystemError(e);
        }
    }
}
"""
    write(os.path.join(OUT_DIR, "BaseViewModel.java"), base)

    for s in data.get("screens", []):
        name = s["name"]
        cls = f"{name}ViewModel"
        pkg = "app.ui.viewmodel"
        vm = f"""package {pkg};

import java.util.regex.Pattern;

public final class {cls} extends BaseViewModel {{

    public {cls}(UiCallbacks ui) {{
        super(ui);
    }}

    public void submit(final Input input) {{
        executeSafe(() -> {{
            validate(input);
            // TODO: call UseCase here (wire later)
            ui.onSuccess();
        }});
    }}

    private void validate(Input input) {{
{""}
"""
        # Generate validations from spec
        for inp in s.get("inputs", []):
            fid = inp["id"]
            label = inp.get("label", fid)
            required = bool(inp.get("required", False))
            typ = inp.get("type", "string")

            if typ == "string":
                vm += f"""        // {label}
        if (input.{fid} == null) input.{fid} = "";
"""
                if required:
                    vm += f"""        if (input.{fid}.trim().isEmpty()) {{
            ui.onValidationError("{fid}", "{label}は必須です");
            throw new IllegalArgumentException("{label}は必須です");
        }}
"""
                if "min_len" in inp:
                    vm += f"""        if (!input.{fid}.trim().isEmpty() && input.{fid}.length() < {int(inp["min_len"])}) {{
            ui.onValidationError("{fid}", "{label}は{int(inp["min_len"])}文字以上です");
            throw new IllegalArgumentException("{label}は{int(inp["min_len"])}文字以上です");
        }}
"""
                if "max_len" in inp:
                    vm += f"""        if (input.{fid}.length() > {int(inp["max_len"])}) {{
            ui.onValidationError("{fid}", "{label}は{int(inp["max_len"])}文字以内です");
            throw new IllegalArgumentException("{label}は{int(inp["max_len"])}文字以内です");
        }}
"""
                if "pattern" in inp:
                    pat = inp["pattern"].replace("\\", "\\\\").replace('"', '\\"')
                    vm += f"""        if (!input.{fid}.trim().isEmpty() && !Pattern.matches("{pat}", input.{fid}.trim())) {{
            ui.onValidationError("{fid}", "{label}の形式が不正です");
            throw new IllegalArgumentException("{label}の形式が不正です");
        }}
"""
            elif typ in ("int", "long"):
                vm += f"""        // {label}
"""
                if required:
                    vm += f"""        if (input.{fid} == null) {{
            ui.onValidationError("{fid}", "{label}は必須です");
            throw new IllegalArgumentException("{label}は必須です");
        }}
"""
                if "min" in inp:
                    vm += f"""        if (input.{fid} != null && input.{fid} < {int(inp["min"])}) {{
            ui.onValidationError("{fid}", "{label}は{int(inp["min"])}以上です");
            throw new IllegalArgumentException("{label}は{int(inp["min"])}以上です");
        }}
"""
                if "max" in inp:
                    vm += f"""        if (input.{fid} != null && input.{fid} > {int(inp["max"])}) {{
            ui.onValidationError("{fid}", "{label}は{int(inp["max"])}以下です");
            throw new IllegalArgumentException("{label}は{int(inp["max"])}以下です");
        }}
"""

        vm += """    }

    public static final class Input {
"""
        for inp in s.get("inputs", []):
            fid = inp["id"]
            typ = inp.get("type", "string")
            if typ == "string":
                jtyp = "String"
            elif typ == "int":
                jtyp = "Integer"
            elif typ == "long":
                jtyp = "Long"
            else:
                jtyp = "String"
            vm += f"        public {jtyp} {fid};\n"
        vm += """    }
}
"""
        write(os.path.join(OUT_DIR, f"{cls}.java"), vm)

    print("OK: ViewModels generated:", OUT_DIR)

if __name__ == "__main__":
    main()
