package foundation.supabase;

import foundation.guard.Preconditions;

/**
 * SupabaseConfig
 * - RLS assumed
 * - Use anon key + user JWT (recommended) at runtime
 * - This repo focuses on coding only, so values are injected by app layer.
 */
public final class SupabaseConfig {

    private final String baseUrl;   // e.g. https://xxxx.supabase.co
    private final String anonKey;   // public anon key

    public SupabaseConfig(String baseUrl, String anonKey) {
        Preconditions.notEmpty(baseUrl, "baseUrl");
        Preconditions.notEmpty(anonKey, "anonKey");
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.anonKey = anonKey;
    }

    public String baseUrl() { return baseUrl; }
    public String anonKey() { return anonKey; }
}
