#!/usr/bin/env python3
import os, yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SPEC = os.path.join(ROOT, "spec", "inputs.schema.yaml")

JAVA_UI = os.path.join(ROOT, "app", "src", "main", "java", "app", "ui")
FRAG_DIR = os.path.join(JAVA_UI, "fragment")
ACT_DIR  = os.path.join(JAVA_UI, "activity")
RES_LAYOUT = os.path.join(ROOT, "app", "src", "main", "res", "layout")
RES_NAV = os.path.join(ROOT, "app", "src", "main", "res", "navigation")

def ensure_dir(p): os.makedirs(p, exist_ok=True)

def write(path, text):
    ensure_dir(os.path.dirname(path))
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)

def load():
    with open(SPEC, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def snake_to_cap(s):
    return "".join(x[:1].upper()+x[1:] for x in s.split("_") if x)

def main():
    data = load()
    ensure_dir(FRAG_DIR); ensure_dir(ACT_DIR); ensure_dir(RES_LAYOUT); ensure_dir(RES_NAV)

    # navigation graph
    nav = ['<navigation xmlns:android="http://schemas.android.com/apk/res/android"\n'
           '    xmlns:app="http://schemas.android.com/apk/res-auto"\n'
           '    android:id="@+id/nav_graph"\n'
           '    app:startDestination="@id/homeFragment">\n\n']

    # HomeFragment + HostActivity
    write(os.path.join(RES_LAYOUT, "fragment_home.xml"), """<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Home (Generated)"/>
</LinearLayout>
""")

    write(os.path.join(FRAG_DIR, "HomeFragment.java"), """package app.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import app.R;

public final class HomeFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_home, container, false);
    }
}
""")

    write(os.path.join(ACT_DIR, "HostActivity.java"), """package app.ui.activity;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentContainerView;
import app.R;

public final class HostActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_host);
    }
}
""")

    write(os.path.join(RES_LAYOUT, "activity_host.xml"), """<androidx.fragment.app.FragmentContainerView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/nav_host_fragment"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    app:defaultNavHost="true"
    app:navGraph="@navigation/nav_graph"
    android:name="androidx.navigation.fragment.NavHostFragment" />
""")

    nav.append('  <fragment\n'
               '      android:id="@+id/homeFragment"\n'
               '      android:name="app.ui.fragment.HomeFragment"\n'
               '      android:label="Home"/>\n\n')

    # Screen fragments
    for s in data.get("screens", []):
        frag = s["fragment"]
        layout = s["layout"]
        domain = s["domain"]
        name = s["name"]

        # Basic fragment layout with generated inputs
        lines = ['<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"\n'
                 '    android:layout_width="match_parent"\n'
                 '    android:layout_height="match_parent">\n'
                 '  <LinearLayout\n'
                 '      android:orientation="vertical"\n'
                 '      android:padding="16dp"\n'
                 '      android:layout_width="match_parent"\n'
                 '      android:layout_height="wrap_content">\n\n'
                 f'    <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="{domain}:{name}"/>\n\n']
        for inp in s.get("inputs", []):
            iid = inp["id"]
            label = inp.get("label", iid)
            typ = inp.get("type", "string")
            view_id = f"input_{iid}"
            lines.append(f'    <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="{label}"/>\n')
            if typ in ("int","long"):
                lines.append(f'    <EditText android:id="@+id/{view_id}" android:inputType="number" android:layout_width="match_parent" android:layout_height="wrap_content"/>\n\n')
            else:
                lines.append(f'    <EditText android:id="@+id/{view_id}" android:layout_width="match_parent" android:layout_height="wrap_content"/>\n\n')

        lines.append('    <Button android:id="@+id/btn_submit" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Submit"/>\n')
        lines.append('  </LinearLayout>\n</ScrollView>\n')
        write(os.path.join(RES_LAYOUT, f"{layout}.xml"), "".join(lines))

        # Fragment class wired to ViewModel
        vm_cls = f"{name}ViewModel"
        frag_java = f"""package app.ui.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import app.R;
import app.ui.viewmodel.{vm_cls};

public final class {frag} extends Fragment implements {vm_cls}.UiCallbacks {{

    private {vm_cls} vm;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {{
        return inflater.inflate(R.layout.{layout}, container, false);
    }}

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {{
        super.onViewCreated(view, savedInstanceState);
        vm = new {vm_cls}(this);

        view.findViewById(R.id.btn_submit).setOnClickListener(v -> {{
            {vm_cls}.Input in = new {vm_cls}.Input();
{""}
"""
        for inp in s.get("inputs", []):
            iid = inp["id"]
            typ = inp.get("type","string")
            vid = f"input_{iid}"
            if typ in ("int","long"):
                frag_java += f"""            try {{
                String t_{iid} = ((android.widget.EditText)view.findViewById(R.id.{vid})).getText().toString().trim();
                in.{iid} = TextUtils.isEmpty(t_{iid}) ? null : Integer.parseInt(t_{iid});
            }} catch (Exception e) {{
                in.{iid} = null;
            }}
"""
            else:
                frag_java += f"""            in.{iid} = ((android.widget.EditText)view.findViewById(R.id.{vid})).getText().toString();
"""
        frag_java += f"""            vm.submit(in);
        }});
    }}

    @Override
    public void onValidationError(String fieldId, String message) {{
        if (getContext() != null) Toast.makeText(getContext(), message, Toast.LENGTH_SHORT).show();
    }}

    @Override
    public void onSystemError(Exception e) {{
        if (getContext() != null) Toast.makeText(getContext(), "System error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
    }}

    @Override
    public void onSuccess() {{
        if (getContext() != null) Toast.makeText(getContext(), "OK", Toast.LENGTH_SHORT).show();
    }}
}}
"""
        write(os.path.join(FRAG_DIR, f"{frag}.java"), frag_java)

        nav.append('  <fragment\n'
                   f'      android:id="@+id/{frag[0].lower()+frag[1:]}"\n'
                   f'      android:name="app.ui.fragment.{frag}"\n'
                   f'      android:label="{name}"/>\n\n')

    nav.append("</navigation>\n")
    write(os.path.join(RES_NAV, "nav_graph.xml"), "".join(nav))

    print("OK: Fragments/HostActivity/Nav generated")

if __name__ == "__main__":
    main()
