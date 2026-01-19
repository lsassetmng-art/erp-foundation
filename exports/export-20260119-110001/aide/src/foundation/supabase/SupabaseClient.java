package foundation.supabase;

import foundation.guard.Preconditions;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * SupabaseClient (thin HTTP layer)
 * - company_id must NEVER be sent
 * - RLS is trusted
 * - Auth token (JWT) can be optionally passed from app layer
 */
public final class SupabaseClient {

    private final SupabaseConfig config;
    private volatile String bearerToken; // optional JWT (user session)

    public SupabaseClient(SupabaseConfig config) {
        this.config = config;
    }

    /** Optional: set user JWT for RLS policies that depend on auth.uid() */
    public void setBearerToken(String jwt) {
        this.bearerToken = jwt;
    }

    public String get(String pathAndQuery) throws Exception {
        return request("GET", pathAndQuery, null);
    }

    public String post(String pathAndQuery, String jsonBody) throws Exception {
        Preconditions.notEmpty(jsonBody, "jsonBody");
        return request("POST", pathAndQuery, jsonBody);
    }

    public String patch(String pathAndQuery, String jsonBody) throws Exception {
        Preconditions.notEmpty(jsonBody, "jsonBody");
        return request("PATCH", pathAndQuery, jsonBody);
    }

    private String request(String method, String pathAndQuery, String jsonBody) throws Exception {
        if (pathAndQuery == null || !pathAndQuery.startsWith("/")) {
            throw new IllegalArgumentException("pathAndQuery must start with '/'");
        }

        // Safety: block company_id being sent by mistake
        if (pathAndQuery.contains("company_id")) {
            throw new IllegalStateException("Forbidden: company_id in request");
        }
        if (jsonBody != null && jsonBody.contains("\"company_id\"")) {
            throw new IllegalStateException("Forbidden: company_id in request body");
        }

        String urlStr = config.baseUrl() + pathAndQuery;
        URL url = new URL(urlStr);
        HttpURLConnection c = (HttpURLConnection) url.openConnection();
        c.setRequestMethod(method);
        c.setRequestProperty("apikey", config.anonKey());
        c.setRequestProperty("Content-Type", "application/json");
        // If you use Supabase REST with JWT:
        // Authorization: Bearer <jwt>
        String jwt = bearerToken;
        if (jwt != null && !jwt.isEmpty()) {
            c.setRequestProperty("Authorization", "Bearer " + jwt);
        } else {
            // fallback (not recommended for authenticated endpoints)
            c.setRequestProperty("Authorization", "Bearer " + config.anonKey());
        }

        if (jsonBody != null) {
            c.setDoOutput(true);
            try (OutputStream os = c.getOutputStream()) {
                os.write(jsonBody.getBytes("UTF-8"));
            }
        }

        int code = c.getResponseCode();
        BufferedReader br = new BufferedReader(new InputStreamReader(
                code >= 400 ? c.getErrorStream() : c.getInputStream()
        ));

        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line).append('\n');

        if (code >= 400) {
            throw new IllegalStateException("Supabase HTTP " + code + ": " + sb.toString());
        }
        return sb.toString();
    }
}
