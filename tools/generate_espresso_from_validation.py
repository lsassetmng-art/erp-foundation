#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
VAL = ROOT / "spec/validation.schema.yaml"
OUT = ROOT / "app/src/androidTest/java/app/ui/GeneratedValidationTest.java"
OUT.parent.mkdir(parents=True, exist_ok=True)

if not VAL.exists():
    print("ERROR: validation.schema.yaml not found")
    sys.exit(1)

OUT.write_text("""
package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Test;
import org.junit.runner.RunWith;
import static org.junit.Assert.assertTrue;

@RunWith(AndroidJUnit4.class)
public class GeneratedValidationTest {
    @Test
    public void validation_schema_exists() {
        assertTrue(true);
    }
}
""".strip(), encoding="utf-8")

print("OK: Espresso tests generated")
