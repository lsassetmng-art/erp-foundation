package com.lsam.MoneySelfManager.foundation.model;

import java.util.ArrayList;
import java.util.List;

public final class LoginResult {
    public boolean success;
    public String userId;
    public String companyId;
    public List<String> roles = new ArrayList<>();
    public List<String> permissions = new ArrayList<>();
    public List<String> licenseCodes = new ArrayList<>();
    public String accessToken; // Supabase JWT (session access_token)
    public long issuedAtEpochMs;
    public FoundationState foundationState = FoundationState.FOUNDATION_UNKNOWN;

    public String errorMessage;

    public static LoginResult fail(String msg) {
        LoginResult r = new LoginResult();
        r.success = false;
        r.errorMessage = msg;
        return r;
    }
}
