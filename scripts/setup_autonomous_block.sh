#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== SETUP AUTONOMOUS BLOCK START ==="

mkdir -p scripts reports spec roles .github/workflows

# ==================================================
# ① check_spec_diff.sh
# ==================================================
cat << 'SH' > scripts/check_spec_diff.sh
#!/data/data/com.termux/files/usr/bin/bash
set -e

SPEC_FILE="spec/usecases.schema.yaml"
REPORT_DIR="reports"
DIFF_REPORT="$REPORT_DIR/spec_diff.txt"

mkdir -p "$REPORT_DIR"

if [ ! -f "$SPEC_FILE" ]; then
  echo "No spec found, skip diff"
  exit 0
fi

if [ ! -f "$REPORT_DIR/last_spec.yaml" ]; then
  cp "$SPEC_FILE" "$REPORT_DIR/last_spec.yaml"
  echo "Initial spec snapshot created"
  exit 0
fi

diff -u "$REPORT_DIR/last_spec.yaml" "$SPEC_FILE" > "$DIFF_REPORT" || true

cp "$SPEC_FILE" "$REPORT_DIR/last_spec.yaml"

if [ -s "$DIFF_REPORT" ]; then
  echo "Spec diff detected"
else
  echo "No spec changes"
fi
SH
chmod +x scripts/check_spec_diff.sh

# ==================================================
# ② policy_next.yaml（次やるべき設計）
# ==================================================
cat << 'YAML' > spec/policy_next.yaml
policy:
  when_spec_changed:
    architect:
      - review_domain_flow
      - check_risk_points
      - update_architecture_notes
    coder:
      - regenerate_usecases
      - update_tests
    reviewer:
      - run_company_id_guard
      - validate_no_direct_db_access
YAML

# ==================================================
# ③ AI社員ロール定義
# ==================================================
cat << 'MD' > roles/ARCHITECT.md
# AI Architect Role
- Interpret spec diff
- Decide next design actions
- Update policy_next.yaml
MD

cat << 'MD' > roles/CODER.md
# AI Coder Role
- Generate code from spec
- Must follow policy_next.yaml
- No company_id handling
MD

cat << 'MD' > roles/REVIEWER.md
# AI Reviewer Role
- Enforce guards
- Reject company_id leakage
- Block unsafe commits
MD

# ==================================================
# CI下地（Actions）
# ==================================================
cat << 'YML' > .github/workflows/auto-review.yml
name: Auto Review

on:
  push:
    branches: [ main ]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check spec diff
        run: bash scripts/check_spec_diff.sh
YML

echo "✅ Autonomous block setup completed"
echo "=== SETUP AUTONOMOUS BLOCK END ==="
