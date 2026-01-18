package foundation.session;

import foundation.guard.Preconditions;

/**
 * SessionManager (Source of truth for session state)
 *
 * Hard rules:
 * - company_id is managed ONLY here
 * - company_id must NOT be exposed publicly (RLS assumed)
 * - Fail-fast when uninitialized
 */
public final class SessionManager {

    private static volatile SessionManager INSTANCE;

    private final String companyId; // hidden (package-private accessor only)
    private final String userId;

    private SessionManager(String companyId, String userId) {
        Preconditions.notEmpty(companyId, "companyId");
        // userId may be null depending on auth strategy
        this.companyId = companyId;
        this.userId = userId;
    }

    /** Initialize once after login/auth success. Idempotent. */
    public static synchronized void init(String companyId, String userId) {
        if (INSTANCE != null) return;
        INSTANCE = new SessionManager(companyId, userId);
    }

    /** Require initialized session. */
    public static SessionManager get() {
        if (INSTANCE == null) {
            throw new IllegalStateException("SessionManager not initialized");
        }
        return INSTANCE;
    }

    /** Clear session (logout). */
    public static synchronized void clear() {
        INSTANCE = null;
    }

    /** Visible for session-related internal components ONLY (package-private). */
    String internalCompanyId() {
        return companyId;
    }

    /** User id is allowed to be public if needed. */
    public String userId() {
        return userId;
    }
}
