package com.lsam.MoneySelfManager.foundation.config;

import android.content.Context;
import android.content.SharedPreferences;

public final class FoundationConfigStore implements ConfigPort {
    private static final String PREF = "foundation_config";
    private final SharedPreferences sp;

    public FoundationConfigStore(Context ctx) {
        this.sp = ctx.getSharedPreferences(PREF, Context.MODE_PRIVATE);
    }

    @Override
    public String getString(String key, String defVal) {
        return sp.getString(key, defVal);
    }

    @Override
    public void putString(String key, String value) {
        sp.edit().putString(key, value).apply();
    }
}
