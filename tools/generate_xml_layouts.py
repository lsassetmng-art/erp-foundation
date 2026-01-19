import os

ACT_ROOT = "app/src/main/java/app/activity"
RES_ROOT = "app/src/main/res/layout"
os.makedirs(RES_ROOT, exist_ok=True)

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue

        name = f.replace("Activity.java", "")
        layout = f"activity_{name.lower()}.xml"
        path = os.path.join(RES_ROOT, layout)

        if os.path.exists(path):
            continue

        with open(path, "w") as out:
            out.write(f"""<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="{name}"
        android:textSize="20sp"/>
</LinearLayout>
""")

print("OK: XML layouts generated")
