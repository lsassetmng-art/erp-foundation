package foundation.session;

/**
 * SessionGuard
 * - A tiny helper to enforce init() has happened.
 */
public final class SessionGuard {

    private SessionGuard() {}

    public static void requireInitialized() {
        SessionManager.get(); // fail-fast
    }
}
