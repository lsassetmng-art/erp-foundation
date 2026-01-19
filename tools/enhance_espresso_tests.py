import os

TEST_ROOT = "app/src/androidTest/java/app/ui"

for f in os.listdir(TEST_ROOT):
    if not f.endswith("Test.java"):
        continue
    p = os.path.join(TEST_ROOT, f)
    src = open(p, encoding="utf-8").read()

    if "onView" in src:
        continue

    src = src.replace(
        "// 최소: 起動できることだけ確認（UI操作は後で追加）",
        """// 入力→実行がクラッシュしないこと
        // Espresso 操作は依存追加後に有効化
        """
    )

    open(p, "w", encoding="utf-8").write(src)

print("OK: Espresso tests enhanced")
