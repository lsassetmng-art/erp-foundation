package com.lsam.MoneySelfManager.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import com.lsam.MoneySelfManager.activities.admin.AdminMenuActivity;

public final class AdminMenuLauncher {

    private AdminMenuLauncher(){}

    public static boolean isAdmin(Context c) {
        SharedPreferences sp = c.getSharedPreferences("session", Context.MODE_PRIVATE);
        return sp.getBoolean("is_admin", false);
    }

    public static void launchIfAdmin(Activity a) {
        if (isAdmin(a)) {
            a.startActivity(new Intent(a, AdminMenuActivity.class));
        }
    }
}
