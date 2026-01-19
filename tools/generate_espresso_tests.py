#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEST = ROOT / "app/src/androidTest/java/app/ui"
TEST.mkdir(parents=True, exist_ok=True)

(TEST / "UiEspressoSmokeTest.java").write_text("""
package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.matcher.ViewMatchers.isRoot;

@RunWith(AndroidJUnit4.class)
public class UiEspressoSmokeTest {

    @Rule
    public ActivityTestRule<MainActivity> rule =
        new ActivityTestRule<>(MainActivity.class);

    @Test
    public void app_starts() {
        onView(isRoot()).check((v, e) -> {});
    }
}
""", encoding="utf-8")

print("OK: Espresso test generated")
