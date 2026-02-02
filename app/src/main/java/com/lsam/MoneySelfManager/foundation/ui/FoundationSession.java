package com.lsam.MoneySelfManager.foundation.ui;

import com.lsam.MoneySelfManager.foundation.model.LoginResult;

public final class FoundationSession {
    private static LoginResult current;

    public static void set(LoginResult r) { current = r; }
    public static LoginResult get() { return current; }
    public static void clear() { current = null; }
}
