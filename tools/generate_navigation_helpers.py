import os

ACT_ROOT = "app/src/main/java/app/activity"
OUT_DIR = "app/src/main/java/app/nav"
os.makedirs(OUT_DIR, exist_ok=True)

activities = []  # (domain, className, fqcn)
for root, _, files in os.walk(ACT_ROOT):
    for f in files:
        if f.endswith("Activity.java"):
            domain = os.path.basename(root)
            class_name = f.replace(".java", "")
            pkg = f"app.activity.{domain}"
            fqcn = f"{pkg}.{class_name}"
            activities.append((domain, class_name, fqcn))

routes_path = os.path.join(OUT_DIR, "Routes.java")
nav_path = os.path.join(OUT_DIR, "Navigator.java")

with open(routes_path, "w", encoding="utf-8") as out:
    out.write("package app.nav;\n\n")
    out.write("public final class Routes {\n")
    out.write("  private Routes() {}\n\n")
    for domain, class_name, _ in sorted(activities):
        key = f"{domain.upper()}_{class_name.upper()}"
        out.write(f"  public static final String {key} = \"{domain}/{class_name}\";\n")
    out.write("}\n")

with open(nav_path, "w", encoding="utf-8") as out:
    out.write("package app.nav;\n\n")
    out.write("import android.content.Context;\n")
    out.write("import android.content.Intent;\n\n")
    out.write("public final class Navigator {\n")
    out.write("  private Navigator() {}\n\n")
    out.write("  public static Intent intent(Context ctx, String route) {\n")
    out.write("    switch (route) {\n")
    for domain, class_name, fqcn in sorted(activities):
        key = f"{domain.upper()}_{class_name.upper()}"
        out.write(f"      case Routes.{key}: return new Intent(ctx, {fqcn}.class);\n")
    out.write("      default: throw new IllegalArgumentException(\"Unknown route: \" + route);\n")
    out.write("    }\n")
    out.write("  }\n")
    out.write("}\n")

print("OK: Navigation helpers generated")
