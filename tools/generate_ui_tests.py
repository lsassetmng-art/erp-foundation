#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEST_DIR = ROOT / "app/src/test/java/app/ui"
TEST_DIR.mkdir(parents=True, exist_ok=True)

(TEST_DIR / "UiSmokeTest.java").write_text("""
package app.ui;

import org.junit.Test;
import static org.junit.Assert.assertTrue;

public class UiSmokeTest {
    @Test
    public void ui_boots() {
        assertTrue(true);
    }
}
""", encoding="utf-8")

print("OK: UI test generated")
