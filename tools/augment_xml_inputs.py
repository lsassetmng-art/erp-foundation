import os
import re

LAY_ROOT = "app/src/main/res/layout"

for f in os.listdir(LAY_ROOT):
    if not (f.startswith("activity_") and f.endswith(".xml")):
        continue

    path = os.path.join(LAY_ROOT, f)
    xml = open(path, encoding="utf-8").read()

    if "input_container" in xml:
        continue  # already augmented

    insert = """
    <LinearLayout
        android:id="@+id/input_container"
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:paddingTop="12dp">

        <EditText
            android:id="@+id/input_text"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:hint="Input"/>
    </LinearLayout>
"""

    xml = xml.replace("</LinearLayout>", insert + "\n</LinearLayout>", 1)
    open(path, "w", encoding="utf-8").write(xml)

print("OK: XML input forms added")
