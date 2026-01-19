import os
import re

USECASE_ROOT = "app/src/main/java/app/usecase"
REPO_ROOT = "app/src/main/java/app/repository"
IMPL_ROOT = "app/src/main/java/app/repository/impl"

for root, _, files in os.walk(USECASE_ROOT):
    for f in files:
        if not f.endswith("UseCase.java"):
            continue

        path = os.path.join(root, f)
        with open(path) as fp:
            content = fp.read()

        pkg = re.search(r'package (.*);', content).group(1)
        domain = pkg.split('.')[-1]
        name = f.replace("UseCase.java", "")

        iface = f"{name}Repository"
        impl_dir = os.path.join(IMPL_ROOT, domain)
        os.makedirs(impl_dir, exist_ok=True)

        impl_path = os.path.join(impl_dir, f"{iface}Impl.java")
        if os.path.exists(impl_path):
            continue

        with open(impl_path, "w") as out:
            out.write(f"""package app.repository.impl.{domain};

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.{iface};

public final class {iface}Impl implements {iface} {{

    @Override
    public Object call(Object input) throws Exception {{
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_{domain.lower()}_{name.lower()}",
            params
        );
    }}
}}
""")

print("OK: Repository impl generated")
