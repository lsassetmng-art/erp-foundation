import os

ACT_ROOT = "app/src/main/java/app/activity"
OUT_ROOT = "app/src/androidTest/java/app/ui"
os.makedirs(OUT_ROOT, exist_ok=True)

for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if not f.endswith("Activity.java"):
            continue
        domain = os.path.basename(root)
        name = f.replace(".java", "")
        test_path = os.path.join(OUT_ROOT, f"{name}Test.java")
        if os.path.exists(test_path):
            continue

        # packageは固定（androidTest）
        with open(test_path, "w", encoding="utf-8") as out:
            out.write(f"""package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import app.activity.{domain}.{name};

@RunWith(AndroidJUnit4.class)
public class {name}Test {{

    @Rule
    public ActivityTestRule<{name}> rule = new ActivityTestRule<>({name}.class);

    @Test
    public void launch_should_succeed() {{
        // 최소: 起動できることだけ確認（UI操作は後で追加）
    }}
}}
""")

print("OK: Espresso tests generated")
