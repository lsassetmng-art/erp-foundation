package com.lsam.MoneySelfManager.foundation.auth;

import com.lsam.MoneySelfManager.foundation.model.FoundationState;
import com.lsam.MoneySelfManager.foundation.model.LoginResult;
import com.lsam.MoneySelfManager.foundation.network.SupabaseMiniHttp;

import org.json.JSONArray;
import org.json.JSONObject;

public final class AuthRepository implements AuthPort {

    private static String cachedAccessToken = null;
    private static LoginResult cachedSession = null;

    @Override
    public LoginResult login(String email, String password) {
        try {
            // 1) Supabase Auth password grant
            JSONObject body = new JSONObject();
            body.put("email", email);
            body.put("password", password);

            // supabase: POST /auth/v1/token?grant_type=password
            JSONObject res = SupabaseMiniHttp.postJson("/auth/v1/token?grant_type=password", body, null);
            int code = res.getInt("_http_code");
            String raw = res.getString("_body");
            if (code < 200 || code >= 300) {
                return LoginResult.fail("Auth failed: " + raw);
            }

            JSONObject authJson = new JSONObject(raw);
            String accessToken = authJson.optString("access_token", null);
            JSONObject user = authJson.optJSONObject("user");
            String userId = (user != null) ? user.optString("id", null) : null;

            if (accessToken == null || userId == null) {
                return LoginResult.fail("Auth parse failed: " + raw);
            }

            // 2) RPC: foundation context
            JSONObject ctxRes = SupabaseMiniHttp.postJson("/rest/v1/rpc/get_my_foundation_context", new JSONObject(), accessToken);
            int ctxCode = ctxRes.getInt("_http_code");
            String ctxRaw = ctxRes.getString("_body");
            if (ctxCode < 200 || ctxCode >= 300) {
                // company_user未登録など
                LoginResult r = new LoginResult();
                r.success = true;
                r.userId = userId;
                r.accessToken = accessToken;
                r.issuedAtEpochMs = System.currentTimeMillis();
                r.foundationState = FoundationState.FOUNDATION_NEEDS_SETUP;
                cachedAccessToken = accessToken;
                cachedSession = r;
                return r;
            }

            JSONObject ctx = new JSONObject(ctxRaw);

            LoginResult r = new LoginResult();
            r.success = true;
            r.userId = ctx.optString("user_id", userId);
            r.companyId = ctx.optString("company_id", null);
            r.accessToken = accessToken;
            r.issuedAtEpochMs = System.currentTimeMillis();

            JSONArray roles = ctx.optJSONArray("roles");
            if (roles != null) for (int i = 0; i < roles.length(); i++) r.roles.add(roles.getString(i));

            JSONArray perms = ctx.optJSONArray("permissions");
            if (perms != null) for (int i = 0; i < perms.length(); i++) r.permissions.add(perms.getString(i));

            JSONArray lic = ctx.optJSONArray("license_codes");
            if (lic != null) for (int i = 0; i < lic.length(); i++) r.licenseCodes.add(lic.getString(i));

            // foundation state判定（最小）
            if (r.companyId == null || r.companyId.isEmpty()) {
                r.foundationState = FoundationState.FOUNDATION_NEEDS_SETUP;
            } else if (r.licenseCodes.isEmpty()) {
                r.foundationState = FoundationState.FOUNDATION_LICENSE_MISSING;
            } else {
                r.foundationState = FoundationState.FOUNDATION_OK;
            }

            cachedAccessToken = accessToken;
            cachedSession = r;
            return r;

        } catch (Exception e) {
            e.printStackTrace();
            return LoginResult.fail("Exception: " + e.getMessage());
        }
    }

    @Override
    public LoginResult getCurrentSession() {
        return cachedSession;
    }

    @Override
    public void logout() {
        cachedAccessToken = null;
        cachedSession = null;
    }
}
