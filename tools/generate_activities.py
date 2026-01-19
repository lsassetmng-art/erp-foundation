import os
import re

VM_ROOT = "app/src/main/java/app/viewmodel"
ACT_ROOT = "app/src/main/java/app/activity"

for root, _, files in os.walk(VM_ROOT):
    for f in files:
        if not f.endswith("ViewModel.java"):
            continue

        path = os.path.join(root, f)
        with open(path) as fp:
            content = fp.read()

        pkg = re.search(r'package (.*);', content).group(1)
        domain = pkg.split('.')[-1]
        name = f.replace("ViewModel.java", "")

        act_dir = os.path.join(ACT_ROOT, domain)
        os.makedirs(act_dir, exist_ok=True)

        act_path = os.path.join(act_dir, f"{name}Activity.java")
        if os.path.exists(act_path):
            continue

        with open(act_path, "w") as out:
            out.write(f"""package app.activity.{domain};

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public final class {name}Activity extends AppCompatActivity {{

    @Override
    protected void onCreate(Bundle savedInstanceState) {{
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.activity_{name.lower()});
    }}
}}
""")

print("OK: Activities generated")
