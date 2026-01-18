#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== ERP Foundation : FULL BOOTSTRAP START ==="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

# -------------------------------------------------
# 1. 基本フォルダ
# -------------------------------------------------
echo "[1/6] Create base directories"
mkdir -p \
  tools \
  spec \
  logs \
  app/src/main/java/app/usecase \
  app/src/main/java/app/ui/common \
  app/src/main/java/app/ui/order \
  app/src/main/java/app/viewmodel/order \
  app/src/main/java/foundation/session \
  app/src/main/java/foundation/network \
  app/src/main/java/foundation/repository \
  app/src/main/java/foundation/cache/db \
  app/src/main/java/foundation/cache/dao

# -------------------------------------------------
# 2. auto_commit.sh
# -------------------------------------------------
echo "[2/6] Create auto_commit.sh"
cat << 'EOF' > scripts/auto_commit.sh
#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="main"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/auto_commit.log"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$LOG_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not a git repo" >> "$LOG_FILE"
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
  echo "ERROR: branch is $CURRENT_BRANCH" >> "$LOG_FILE"
  exit 1
fi

if git diff --quiet && git diff --cached --quiet; then
  echo "No changes" >> "$LOG_FILE"
  exit 0
fi

git add .
git commit -m "auto: update generated files ($TIMESTAMP)" >> "$LOG_FILE" 2>&1

if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  git push -u origin "$BRANCH" >> "$LOG_FILE" 2>&1
else
  git push >> "$LOG_FILE" 2>&1
fi

echo "PUSH OK" >> "$LOG_FILE"
EOF
chmod +x scripts/auto_commit.sh

# -------------------------------------------------
# 3. Session / RPC 基盤
# -------------------------------------------------
echo "[3/6] Create Session / Network / Repository"

cat << 'JAVA' > app/src/main/java/foundation/session/SessionManager.java
package foundation.session;

public final class SessionManager {

    private static SessionManager instance;

    private String accessToken;
    private String userId;
    private String companyId;

    private SessionManager() {}

    public static synchronized SessionManager getInstance() {
        if (instance == null) instance = new SessionManager();
        return instance;
    }

    public void init(String accessToken, String userId, String companyId) {
        this.accessToken = accessToken;
        this.userId = userId;
        this.companyId = companyId;
    }

    public boolean isLoggedIn() {
        return accessToken != null && !accessToken.isEmpty();
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getUserId() {
        return userId;
    }

    String getCompanyIdInternal() {
        return companyId;
    }

    public void clear() {
        accessToken = null;
        userId = null;
        companyId = null;
    }
}
JAVA

cat << 'JAVA' > app/src/main/java/foundation/network/RpcClient.java
package foundation.network;

import org.json.JSONObject;
import foundation.session.SessionManager;

public final class RpcClient {

    private static final String BASE_URL =
        "https://YOUR_PROJECT_ID.supabase.co/rest/v1/rpc/";

    public static JSONObject post(String action, JSONObject payload) throws Exception {
        // 実装は後で差し替え
        return new JSONObject();
    }
}
JAVA

cat << 'JAVA' > app/src/main/java/foundation/repository/RpcRepository.java
package foundation.repository;

import org.json.JSONObject;
import foundation.network.RpcClient;

public abstract class RpcRepository {

    protected JSONObject callRpc(String action, JSONObject payload) throws Exception {
        return RpcClient.post(action, payload);
    }
}
JAVA

# -------------------------------------------------
# 4. ViewModel / UI 雛形
# -------------------------------------------------
echo "[4/6] Create ViewModel / UI skeleton"

cat << 'JAVA' > app/src/main/java/app/ui/common/BaseViewModel.java
package app.ui.common;

public abstract class BaseViewModel {

    private boolean loading;
    private String errorMessage;

    public boolean isLoading() { return loading; }
    protected void setLoading(boolean v) { loading = v; }

    public String getErrorMessage() { return errorMessage; }
    protected void setErrorMessage(String m) { errorMessage = m; }
}
JAVA

# -------------------------------------------------
# 5. SQLite Cache（Read-only）
# -------------------------------------------------
echo "[5/6] Create SQLite cache skeleton"

cat << 'JAVA' > app/src/main/java/foundation/cache/db/CacheDatabaseHelper.java
package foundation.cache.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public final class CacheDatabaseHelper extends SQLiteOpenHelper {

    public CacheDatabaseHelper(Context c) {
        super(c, "erp_cache.db", null, 1);
    }

    @Override public void onCreate(SQLiteDatabase db) {}
    @Override public void onUpgrade(SQLiteDatabase db, int o, int n) {}
}
JAVA

cat << 'JAVA' > app/src/main/java/foundation/cache/dao/BaseCacheDao.java
package foundation.cache.dao;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import foundation.cache.db.CacheDatabaseHelper;

public abstract class BaseCacheDao {

    protected final SQLiteDatabase db;

    protected BaseCacheDao(Context c) {
        db = new CacheDatabaseHelper(c).getReadableDatabase();
    }
}
JAVA

# -------------------------------------------------
# 6. 完了
# -------------------------------------------------
echo "[6/6] Done"
echo "=== ERP Foundation : FULL BOOTSTRAP COMPLETE ==="
echo "Next: ./scripts/full_generate.sh or ./scripts/auto_commit.sh"
