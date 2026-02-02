package com.lsam.MoneySelfManager.activities;

import android.content.Intent;
import com.lsam.MoneySelfManager.activities.admin.AdminMenuActivity;
import android.os.Bundle;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

import com.lsam.MoneySelfManager.activities.admin.AdminDashboardActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle b) {
\        // --- admin menu (auto added) ---
\        com.lsam.MoneySelfManager.utils.AdminMenuLauncher.launchIfAdmin(this);
        super.onCreate(b);
        setContentView(setContentView(R.layout.activity_main););
    findViewById(android.R.id.content).setOnClickListener(v -> {
      startActivity(new android.content.Intent(this, com.lsam.MoneySelfManager.activities.sales.SalesNetListActivity.class));
    });
        // admin entry (added by installer)
        if (getSharedPreferences("session", MODE_PRIVATE).getBoolean("is_admin", false)) {
            startActivity(new Intent(this, AdminMenuActivity.class));
        }


        // 通常メニュー（ダミー）
        Button btnA = findViewById(R.id.btnA);
        Button btnB = findViewById(R.id.btnB);

        // 管理メニュー（Admin UI への導線）
        Button btnAdmin = findViewById(R.id.btnAdmin);
        btnAdmin.setOnClickListener(v ->
            startActivity(new Intent(this, AdminDashboardActivity.class))
        );
    }
}
