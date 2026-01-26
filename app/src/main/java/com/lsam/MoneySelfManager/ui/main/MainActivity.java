package com.lsam.MoneySelfManager.ui.main;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.activities.admin.AdminMenuActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_main);

        SharedPreferences sp = getSharedPreferences("session", MODE_PRIVATE);
        boolean isAdmin = sp.getBoolean("is_admin", false);

        if (isAdmin) {
            startActivity(new Intent(this, AdminMenuActivity.class));
            finish();
            return;
        }

        // 非管理者（将来 UserMenuActivity へ）
        // いまは何もしない（Entryとして待機）
    }
}
