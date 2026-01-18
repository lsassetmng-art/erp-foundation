#!/usr/bin/env python3
import os, yaml

ROOT = os.getcwd()
SPEC = os.path.join(ROOT, "spec", "usecases.schema.yaml")
JAVA = os.path.join(ROOT, "app", "src", "main", "java")

def ensure(p):
    os.makedirs(p, exist_ok=True)

with open(SPEC, "r", encoding="utf-8") as f:
    spec = yaml.safe_load(f)

for uc in spec.get("usecases", []):
    domain = uc["domain"]
    name = uc["name"]

    # ----------------------------
    # ViewModel
    # ----------------------------
    vm_dir = os.path.join(JAVA, "app", "viewmodel", domain)
    ensure(vm_dir)

    vm_path = os.path.join(vm_dir, f"{name}ViewModel.java")

    with open(vm_path, "w", encoding="utf-8") as w:
        w.write(f"""package app.viewmodel.{domain};

import app.ui.common.BaseViewModel;
import app.usecase.{domain}.{name}UseCase;
import app.usecase.{domain}.{name}Input;
import app.usecase.{domain}.{name}Result;

/**
 * {name}ViewModel
 * - 自動生成
 * - UI → ViewModel → UseCase
 */
public final class {name}ViewModel extends BaseViewModel {{

    private final {name}UseCase useCase;
    private {name}Result lastResult;

    public {name}ViewModel({name}UseCase useCase) {{
        this.useCase = useCase;
    }}

    public void execute({name}Input input) {{
        try {{
            setLoading(true);
            setErrorMessage(null);
            lastResult = useCase.execute(input);
        }} catch (Exception e) {{
            setErrorMessage(e.getMessage());
        }} finally {{
            setLoading(false);
        }}
    }}

    public {name}Result getLastResult() {{
        return lastResult;
    }}
}}
""")

    # ----------------------------
    # CacheDao（Read-only）
    # ----------------------------
    dao_dir = os.path.join(JAVA, "foundation", "cache", "dao")
    ensure(dao_dir)

    dao_path = os.path.join(dao_dir, f"{name}CacheDao.java")

    with open(dao_path, "w", encoding="utf-8") as w:
        w.write(f"""package foundation.cache.dao;

import android.content.Context;
import android.database.Cursor;

/**
 * {name}CacheDao
 * - 自動生成
 * - Read-only キャッシュ
 */
public final class {name}CacheDao extends BaseCacheDao {{

    public {name}CacheDao(Context context) {{
        super(context);
    }}

    public Cursor findAll() {{
        // テーブル名は後で同期側が定義
        return db.rawQuery(
            "SELECT * FROM {name.lower()}_cache",
            null
        );
    }}
}}
""")

print("OK: ViewModel / CacheDao generated")
