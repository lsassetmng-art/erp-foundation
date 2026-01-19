import os, pathlib

ACT_ROOT = pathlib.Path("app/src/main/java/app/activity")
OUT_JAVA = pathlib.Path("app/src/main/java/app/activity/core/HomeActivity.java")
OUT_XML  = pathlib.Path("app/src/main/res/layout/activity_home.xml")
DOC      = pathlib.Path("docs/manifest_additions.md")

OUT_JAVA.parent.mkdir(parents=True, exist_ok=True)
OUT_XML.parent.mkdir(parents=True, exist_ok=True)
DOC.parent.mkdir(parents=True, exist_ok=True)

# collect activities (exclude HomeActivity itself)
acts = []
for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if f.endswith("Activity.java") and f != "HomeActivity.java":
            domain = os.path.basename(root)
            class_name = f[:-5]
            pkg = f"app.activity.{domain}"
            fqcn = f"{pkg}.{class_name}"
            route = f"{domain}/{class_name}"
            acts.append((route, fqcn, class_name))

acts.sort()

# XML
OUT_XML.write_text("""<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Home"
        android:textSize="20sp"
        android:paddingBottom="12dp"/>

    <ListView
        android:id="@+id/list_routes"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
</LinearLayout>
""", encoding="utf-8")

# Java (ListView menu)
items = ",\n            ".join([f"\"{r}\"" for r,_,_ in acts]) or "\"(no routes)\""

OUT_JAVA.write_text(f"""package app.activity.core;

import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import androidx.appcompat.app.AppCompatActivity;

import app.nav.Navigator;

public final class HomeActivity extends AppCompatActivity {{

    @Override
    protected void onCreate(Bundle savedInstanceState) {{
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        ListView list = findViewById(R.id.list_routes);
        String[] routes = new String[] {{
            {items}
        }};

        ArrayAdapter<String> adapter =
                new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, routes);
        list.setAdapter(adapter);

        list.setOnItemClickListener((parent, view, pos, id) -> {{
            String route = routes[pos];
            startActivity(Navigator.intent(this, route));
        }});
    }}
}}
""", encoding="utf-8")

# Manifest guidance
DOC.write_text("""# AndroidManifest 追加（手動1回）

Home を起点にする場合、AndroidManifest.xml に以下を追加してください。

- HomeActivity を LAUNCHER にする
- 既存の LAUNCHER Activity がある場合は置き換え

例（概念）:
<activity android:name="app.activity.core.HomeActivity">
  <intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
  </intent-filter>
</activity>
""", encoding="utf-8")

print("OK: Home menu generated (HomeActivity + activity_home.xml + docs/manifest_additions.md)")
