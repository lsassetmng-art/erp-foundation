from __future__ import annotations
from pathlib import Path
from typing import Any, Dict, Tuple

from spec_loader import load_inputs_spec

ROOT = Path(__file__).resolve().parents[1]

DTO_DIR = ROOT / "app/src/main/java/app/ui/dto"
VM_DIR  = ROOT / "app/src/main/java/app/ui/viewmodel"
UC_DIR  = ROOT / "app/src/main/java/app/usecase"
FR_DIR  = ROOT / "app/src/main/java/app/ui/fragment"
LAY_DIR = ROOT / "app/src/main/res/layout"
NAV_DIR = ROOT / "app/src/main/res/navigation"
TST_DIR = ROOT / "app/src/androidTest/java/app/ui"
REP_DIR = ROOT / "reports"

for d in [DTO_DIR, VM_DIR, UC_DIR, FR_DIR, LAY_DIR, NAV_DIR, TST_DIR, REP_DIR]:
    d.mkdir(parents=True, exist_ok=True)

spec = load_inputs_spec(ROOT)
screens = spec.get("screens") or []
if not isinstance(screens, list) or not screens:
    raise SystemExit("ERROR: spec/inputs.schema.yaml has no screens")

def jtype(rule: Dict[str, Any]) -> str:
    t = str(rule.get("type", "string"))
    if t in ("int", "integer", "number"): return "Integer"
    if t in ("long",): return "Long"
    return "String"

def cap(s: str) -> str:
    return s[:1].upper() + s[1:] if s else s

# -------- DTO + UseCase + ViewModel + Fragment + XML --------
nav_frag_entries = []
for s in screens:
    name = s.get("name")
    fields: Dict[str, Dict[str, Any]] = (s.get("fields") or {})
    if not name or not isinstance(fields, dict) or not fields:
        continue

    dto_cls = f"{name}Input"
    vm_cls  = f"{name}ViewModel"
    uc_cls  = f"{name}UseCase"
    fr_cls  = f"{name}Fragment"
    layout  = f"fragment_{name.lower()}"

    # DTO
    dto_lines = [f"package app.ui.dto;", "", f"public final class {dto_cls} {{", ""]
    for fid, rule in fields.items():
        dto_lines.append(f"    private {jtype(rule)} {fid};")
    dto_lines.append("")
    for fid, rule in fields.items():
        jt = jtype(rule)
        dto_lines.append(f"    public {jt} get{cap(fid)}() {{ return {fid}; }}")
        dto_lines.append(f"    public void set{cap(fid)}({jt} {fid}) {{ this.{fid} = {fid}; }}")
    dto_lines.append("}")
    (DTO_DIR / f"{dto_cls}.java").write_text("\n".join(dto_lines), encoding="utf-8")

    # UseCase (stub)
    uc = f"""package app.usecase;

import app.ui.dto.{dto_cls};

public final class {uc_cls} {{
    public void execute({dto_cls} input) {{
        // TODO: connect repository / RPC here (RLS前提, company_idは扱わない)
    }}
}}
"""
    (UC_DIR / f"{uc_cls}.java").write_text(uc, encoding="utf-8")

    # ViewModel (executeSafe + field errors + UseCase接続)
    # Validation rules supported: required, minLength, maxLength, min, max, format=email
    vml = []
    vml.append("package app.ui.viewmodel;")
    vml.append("")
    vml.append("import java.util.regex.Pattern;")
    vml.append("import app.ui.dto.%s;" % dto_cls)
    vml.append("import app.usecase.%s;" % uc_cls)
    vml.append("")
    vml.append("public final class %s {" % vm_cls)
    vml.append("")
    vml.append("    public interface UiCallbacks {")
    vml.append("        void onFieldError(String fieldId, String message);")
    vml.append("        void onFormError(String message);")
    vml.append("        void onSystemError(Exception e);")
    vml.append("        void onSuccess();")
    vml.append("    }")
    vml.append("")
    vml.append("    private final UiCallbacks ui;")
    vml.append("    private final %s useCase;" % uc_cls)
    vml.append("")
    vml.append("    public %s(UiCallbacks ui) {" % vm_cls)
    vml.append("        this.ui = ui;")
    vml.append("        this.useCase = new %s();" % uc_cls)
    vml.append("    }")
    vml.append("")
    vml.append("    public void submit(%s input) {" % dto_cls)
    vml.append("        executeSafe(() -> {")
    vml.append("            validate(input);")
    vml.append("            useCase.execute(input);")
    vml.append("            ui.onSuccess();")
    vml.append("            return null;")
    vml.append("        });")
    vml.append("    }")
    vml.append("")
    vml.append("    private void validate(%s input) {" % dto_cls)

    for fid, rule in fields.items():
        label = fid
        required = bool(rule.get("required", False))
        t = str(rule.get("type", "string"))
        fmt = str(rule.get("format", ""))
        min_len = rule.get("minLength")
        max_len = rule.get("maxLength")
        min_v = rule.get("min")
        max_v = rule.get("max")

        if t in ("int", "integer", "number", "long"):
            if required:
                vml.append(f"        if (input.get{cap(fid)}() == null) fieldFail(\"{fid}\", \"{label}は必須です\");")
            if min_v is not None:
                vml.append(f"        if (input.get{cap(fid)}() != null && input.get{cap(fid)}() < {int(min_v)}) fieldFail(\"{fid}\", \"{label}は{int(min_v)}以上です\");")
            if max_v is not None:
                vml.append(f"        if (input.get{cap(fid)}() != null && input.get{cap(fid)}() > {int(max_v)}) fieldFail(\"{fid}\", \"{label}は{int(max_v)}以下です\");")
        else:
            vml.append(f"        String v_{fid} = input.get{cap(fid)}();")
            vml.append(f"        if (v_{fid} == null) v_{fid} = \"\";")
            if required:
                vml.append(f"        if (v_{fid}.trim().isEmpty()) fieldFail(\"{fid}\", \"{label}は必須です\");")
            if min_len is not None:
                vml.append(f"        if (!v_{fid}.trim().isEmpty() && v_{fid}.length() < {int(min_len)}) fieldFail(\"{fid}\", \"{label}は{int(min_len)}文字以上です\");")
            if max_len is not None:
                vml.append(f"        if (v_{fid}.length() > {int(max_len)}) fieldFail(\"{fid}\", \"{label}は{int(max_len)}文字以内です\");")
            if fmt == "email":
                vml.append(f"        if (!v_{fid}.trim().isEmpty() && !Pattern.matches(\"^[^@\\\\s]+@[^@\\\\s]+\\\\.[^@\\\\s]+$\", v_{fid}.trim())) fieldFail(\"{fid}\", \"{label}の形式が不正です\");")

    vml.append("    }")
    vml.append("")
    vml.append("    private void fieldFail(String fieldId, String message) {")
    vml.append("        ui.onFieldError(fieldId, message);")
    vml.append("        throw new IllegalArgumentException(message);")
    vml.append("    }")
    vml.append("")
    vml.append("    private <T> void executeSafe(Callable<T> action) {")
    vml.append("        try {")
    vml.append("            action.call();")
    vml.append("        } catch (IllegalArgumentException e) {")
    vml.append("            ui.onFormError(e.getMessage());")
    vml.append("        } catch (Exception e) {")
    vml.append("            ui.onSystemError(e);")
    vml.append("        }")
    vml.append("    }")
    vml.append("")
    vml.append("    private interface Callable<T> { T call() throws Exception; }")
    vml.append("}")
    (VM_DIR / f"{vm_cls}.java").write_text("\n".join(vml), encoding="utf-8")

    # XML layout (EditText + error-ready)
    # Keep it simple LinearLayout for compatibility; Android Studio OK.
    xml_lines = [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"',
        '    android:layout_width="match_parent"',
        '    android:layout_height="match_parent">',
        '  <LinearLayout',
        '      android:orientation="vertical"',
        '      android:padding="16dp"',
        '      android:layout_width="match_parent"',
        '      android:layout_height="wrap_content">',
        f'    <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="{name}" android:textSize="20sp" />',
        ''
    ]
    for fid, rule in fields.items():
        t = str(rule.get("type","string"))
        it = "number" if t in ("int","integer","number","long") else "text"
        xml_lines += [
            f'    <EditText',
            f'        android:id="@+id/input_{fid}"',
            f'        android:layout_width="match_parent"',
            f'        android:layout_height="wrap_content"',
            f'        android:hint="{fid}"',
            f'        android:inputType="{it}" />',
            ''
        ]
    xml_lines += [
        '    <Button',
        '        android:id="@+id/btn_submit"',
        '        android:layout_width="match_parent"',
        '        android:layout_height="wrap_content"',
        '        android:text="Submit" />',
        '  </LinearLayout>',
        '</ScrollView>',
        ''
    ]
    (LAY_DIR / f"{layout}.xml").write_text("\n".join(xml_lines), encoding="utf-8")

    # Fragment (binds inputs -> DTO -> VM; field error -> setError on that EditText)
    fr = []
    fr.append("package app.ui.fragment;")
    fr.append("")
    fr.append("import android.os.Bundle;")
    fr.append("import android.text.TextUtils;")
    fr.append("import android.view.LayoutInflater;")
    fr.append("import android.view.View;")
    fr.append("import android.view.ViewGroup;")
    fr.append("import android.widget.EditText;")
    fr.append("import android.widget.Toast;")
    fr.append("import androidx.annotation.NonNull;")
    fr.append("import androidx.annotation.Nullable;")
    fr.append("import androidx.fragment.app.Fragment;")
    fr.append("import app.R;")
    fr.append(f"import app.ui.dto.{dto_cls};")
    fr.append(f"import app.ui.viewmodel.{vm_cls};")
    fr.append("")
    fr.append(f"public final class {fr_cls} extends Fragment implements {vm_cls}.UiCallbacks {{")
    fr.append("")
    fr.append(f"    private {vm_cls} vm;")
    fr.append("")
    fr.append("    @Nullable")
    fr.append("    @Override")
    fr.append("    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {")
    fr.append(f"        return inflater.inflate(R.layout.{layout}, container, false);")
    fr.append("    }")
    fr.append("")
    fr.append("    @Override")
    fr.append("    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {")
    fr.append("        super.onViewCreated(view, savedInstanceState);")
    fr.append(f"        vm = new {vm_cls}(this);")
    fr.append("        view.findViewById(R.id.btn_submit).setOnClickListener(v -> {")
    fr.append(f"            {dto_cls} input = new {dto_cls}();")
    for fid, rule in fields.items():
        t = str(rule.get("type","string"))
        fr.append(f"            EditText et_{fid} = view.findViewById(R.id.input_{fid});")
        if t in ("int","integer","number","long"):
            fr.append(f"            Integer val_{fid} = null;")
            fr.append(f"            try {{")
            fr.append(f"                String s = (et_{fid} == null) ? \"\" : et_{fid}.getText().toString().trim();")
            fr.append(f"                val_{fid} = TextUtils.isEmpty(s) ? null : Integer.parseInt(s);")
            fr.append(f"            }} catch (Exception ignore) {{ val_{fid} = null; }}")
            fr.append(f"            input.set{cap(fid)}(val_{fid});")
        else:
            fr.append(f"            String val_{fid} = (et_{fid} == null) ? \"\" : et_{fid}.getText().toString();")
            fr.append(f"            input.set{cap(fid)}(val_{fid});")
    fr.append("            vm.submit(input);")
    fr.append("        });")
    fr.append("    }")
    fr.append("")
    fr.append("    @Override")
    fr.append("    public void onFieldError(String fieldId, String message) {")
    fr.append("        View root = getView();")
    fr.append("        if (root == null) return;")
    fr.append("        int resId = getResources().getIdentifier(\"input_\" + fieldId, \"id\", requireContext().getPackageName());")
    fr.append("        if (resId != 0) {")
    fr.append("            View v = root.findViewById(resId);")
    fr.append("            if (v instanceof EditText) ((EditText) v).setError(message);")
    fr.append("        }")
    fr.append("    }")
    fr.append("")
    fr.append("    @Override")
    fr.append("    public void onFormError(String message) {")
    fr.append("        if (getContext() != null) Toast.makeText(getContext(), message, Toast.LENGTH_SHORT).show();")
    fr.append("    }")
    fr.append("")
    fr.append("    @Override")
    fr.append("    public void onSystemError(Exception e) {")
    fr.append("        if (getContext() != null) Toast.makeText(getContext(), \"System error: \" + e.getMessage(), Toast.LENGTH_SHORT).show();")
    fr.append("    }")
    fr.append("")
    fr.append("    @Override")
    fr.append("    public void onSuccess() {")
    fr.append("        if (getContext() != null) Toast.makeText(getContext(), \"OK\", Toast.LENGTH_SHORT).show();")
    fr.append("    }")
    fr.append("}")
    (FR_DIR / f"{fr_cls}.java").write_text("\n".join(fr), encoding="utf-8")

    nav_frag_entries.append((name, fr_cls))

# nav_graph.xml (startDestination = first screen)
start = nav_frag_entries[0][1] if nav_frag_entries else "HomeFragment"
nav_lines = [
    '<?xml version="1.0" encoding="utf-8"?>',
    '<navigation xmlns:android="http://schemas.android.com/apk/res/android"',
    '    xmlns:app="http://schemas.android.com/apk/res-auto"',
    '    android:id="@+id/nav_graph"',
    f'    app:startDestination="@id/{start[:1].lower()+start[1:]}">',
    ''
]
for _, fr_cls in nav_frag_entries:
    frag_id = fr_cls[:1].lower()+fr_cls[1:]
    nav_lines += [
        '  <fragment',
        f'      android:id="@+id/{frag_id}"',
        f'      android:name="app.ui.fragment.{fr_cls}"',
        f'      android:label="{fr_cls}" />',
        ''
    ]
nav_lines += ['</navigation>', '']
(NAV_DIR / "nav_graph.xml").write_text("\n".join(nav_lines), encoding="utf-8")

# -------- Espresso UI tests (skeleton) --------
# Generates one smoke test per screen: checks submit button exists in layout
for name, _fr in nav_frag_entries:
    test_cls = f"{name}UiSmokeTest"
    layout = f"fragment_{name.lower()}"
    # NOTE: This is a template; running requires AndroidX test deps in Gradle.
    test = f"""package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class {test_cls} {{
    @Test
    public void layout_should_exist_compile_time() {{
        // Smoke: just reference R to ensure resources exist.
        int id = app.R.layout.{layout};
        int btn = app.R.id.btn_submit;
        // no-op
    }}
}}
"""
    (TST_DIR / f"{test_cls}.java").write_text(test, encoding="utf-8")

# -------- AI review (static checks) --------
review = []
# 1) company_id leakage in UI layers
ui_roots = [
    ROOT / "app/src/main/java/app/ui",
    ROOT / "app/src/main/res/layout",
]
hits = []
for base in ui_roots:
    if not base.exists(): 
        continue
    for p in base.rglob("*"):
        if p.is_file() and p.suffix in (".java", ".xml"):
            txt = p.read_text(encoding="utf-8", errors="ignore")
            if "company_id" in txt:
                hits.append(str(p.relative_to(ROOT)))
if hits:
    review.append("## CRITICAL: company_id leak (UI層)\n- " + "\n- ".join(hits))
else:
    review.append("## OK: company_id leak (UI層) none")

# 2) nav_graph has fragments generated
nav_path = NAV_DIR / "nav_graph.xml"
if nav_path.exists():
    nav_txt = nav_path.read_text(encoding="utf-8", errors="ignore")
    missing = []
    for _, fr_cls in nav_frag_entries:
        if f"app.ui.fragment.{fr_cls}" not in nav_txt:
            missing.append(fr_cls)
    if missing:
        review.append("## WARN: nav_graph missing fragments\n- " + "\n- ".join(missing))
    else:
        review.append("## OK: nav_graph fragments present")
else:
    review.append("## WARN: nav_graph.xml not found")

# 3) XML has btn_submit
missing_btn = []
for name, _ in nav_frag_entries:
    lp = LAY_DIR / f"fragment_{name.lower()}.xml"
    if lp.exists():
        txt = lp.read_text(encoding="utf-8", errors="ignore")
        if 'android:id="@+id/btn_submit"' not in txt:
            missing_btn.append(str(lp.relative_to(ROOT)))
if missing_btn:
    review.append("## WARN: layouts missing btn_submit\n- " + "\n- ".join(missing_btn))
else:
    review.append("## OK: layouts have btn_submit")

(REP_DIR / "ai_review_ui.md").write_text("# AI Review (Static)\n\n" + "\n\n".join(review) + "\n", encoding="utf-8")

print("OK: Next-stage applied")
print(" - DTO:      app/src/main/java/app/ui/dto")
print(" - UseCase:  app/src/main/java/app/usecase")
print(" - VM:       app/src/main/java/app/ui/viewmodel")
print(" - Fragment: app/src/main/java/app/ui/fragment")
print(" - XML:      app/src/main/res/layout")
print(" - Nav:      app/src/main/res/navigation/nav_graph.xml")
print(" - Tests:    app/src/androidTest/java/app/ui")
print(" - Review:   reports/ai_review_ui.md")
