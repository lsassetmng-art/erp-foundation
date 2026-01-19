package foundation.session;

/**
 * SessionManager
 *
 * 方針:
 * - company_id はここでのみ保持
 * - 他クラスは company_id に直接アクセス禁止
 * - Supabase RLS 前提
 */
public final class SessionManager {

    private static SessionManager instance;

    private String accessToken;
    private String userId;
    private String companyId;

    private SessionManager() {}

    public static synchronized SessionManager getInstance() {
        if (instance == null) {
            instance = new SessionManager();
        }
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

    // ⚠ company_id は外部に公開しない
    String getCompanyIdInternal() {
        return companyId;
    }

    public void clear() {
        accessToken = null;
        userId = null;
        companyId = null;
    }
}
