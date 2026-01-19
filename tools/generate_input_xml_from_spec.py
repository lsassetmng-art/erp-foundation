import os, re, yaml, pathlib

SPEC = pathlib.Path("spec/inputs.schema.yaml")
LAY_DIR = pathlib.Path("app/src/main/res/layout")
LAY_DIR.mkdir(parents=True, exist_ok=True)

if not SPEC.exists():
    raise SystemExit("ERROR: spec/inputs.schema.yaml not found")

data = yaml.safe_load(SPEC.read_text(encoding="utf-8")) or {}
inputs = (data.get("inputs") or {})

def ensure_layout(layout_path: pathlib.Path, title: str):
    if layout_path.exists():
        return layout_path.read_text(encoding="utf-8")
    # minimal base xml
    return f'''<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
  <LinearLayout
      android:orientation="vertical"
      android:layout_width="match_parent"
      android:layout_height="wrap_content"
      android:padding="16dp">

    <TextView
        android:id="@+id/title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="{title}"
        android:textSize="20sp"
        android:paddingBottom="12dp"/>

    <LinearLayout
        android:id="@+id/input_container"
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>

    <Button
        android:id="@+id/btn_execute"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Execute"
        android:paddingTop="12dp"/>

  </LinearLayout>
</ScrollView>
'''

def upsert_fields(xml: str, fields):
    # ensure container exists
    if 'android:id="@+id/input_container"' not in xml:
        # fallback: append container before closing
        xml = xml.replace("</LinearLayout>", '\n<LinearLayout android:id="@+id/input_container" android:orientation="vertical" android:layout_width="match_parent" android:layout_height="wrap_content"/>\n</LinearLayout>', 1)

    # build field xml blocks
    blocks = []
    for f in fields:
        name = f["name"]
        ftype = f.get("type","string")
        hint = name
        input_type = "text"
        if ftype in ("int","integer","number"):
            input_type = "number"
        blocks.append(f'''
        <EditText
            android:id="@+id/input_{name}"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:hint="{hint}"
            android:inputType="{input_type}" />''')

    # if already inserted marker, do nothing
    if "<!-- AUTO_INPUT_FIELDS -->" in xml:
        # replace entire region between markers
        xml = re.sub(r"<!-- AUTO_INPUT_FIELDS -->(.|\n)*?<!-- /AUTO_INPUT_FIELDS -->",
                     "<!-- AUTO_INPUT_FIELDS -->\n" + "\n".join(blocks) + "\n<!-- /AUTO_INPUT_FIELDS -->",
                     xml)
        return xml

    # insert into container: simplest is to place blocks right after container start tag line
    # find the container end tag if it's self-closing or not—fallback to append blocks near container.
    if "/>" in xml and 'android:id="@+id/input_container"' in xml:
        # self-closing container -> convert to open/close and insert
        xml = xml.replace('android:id="@+id/input_container"\n        android:orientation="vertical"\n        android:layout_width="match_parent"\n        android:layout_height="wrap_content"/>',
                          'android:id="@+id/input_container"\n        android:orientation="vertical"\n        android:layout_width="match_parent"\n        android:layout_height="wrap_content">\n<!-- AUTO_INPUT_FIELDS -->\n' + "\n".join(blocks) + '\n<!-- /AUTO_INPUT_FIELDS -->\n    </LinearLayout>')
        return xml

    # normal container
    xml = xml.replace('android:id="@+id/input_container"',
                      'android:id="@+id/input_container"\n<!-- AUTO_INPUT_FIELDS -->\n' + "\n".join(blocks) + '\n<!-- /AUTO_INPUT_FIELDS -->',
                      1)
    return xml

count = 0
for usecase, conf in inputs.items():
    # layout name convention: activity_<usecase lower>
    layout_name = f"activity_{usecase.lower()}.xml"
    layout_path = LAY_DIR / layout_name
    xml = ensure_layout(layout_path, usecase)
    fields = conf.get("fields") or []
    xml2 = upsert_fields(xml, fields)
    layout_path.write_text(xml2, encoding="utf-8")
    count += 1

print(f"OK: generated/updated {count} XML layouts from spec")
