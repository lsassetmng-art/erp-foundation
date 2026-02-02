package com.lsam.MoneySelfManager.foundation.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.foundation.model.LoginResult;
import com.lsam.MoneySelfManager.foundation.outbox.OutboxDao;

public final class FoundationHomeActivity extends Activity {

    private TextView txtUser;
    private TextView txtCompany;
    private TextView txtState;
    private TextView txtLic;
    private TextView txtOutbox;

    private Button btnMasters;
    private Button btnRetry;
    private Button btnLogout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_foundation_home);

        txtUser   = findViewById(R.id.txtUser);
        txtCompany= findViewById(R.id.txtCompany);
        txtState  = findViewById(R.id.txtState);
        txtLic    = findViewById(R.id.txtLicenses);
        txtOutbox = findViewById(R.id.txtOutbox);

        btnMasters = findViewById(R.id.btnMasters);
        btnRetry   = findViewById(R.id.btnRetryOutbox);
        btnLogout  = findViewById(R.id.btnLogout);

        refresh();

        btnMasters.setOnClickListener(v -> startActivity(new Intent(this, FoundationMasterMenuActivity.class)));
        btnRetry.setOnClickListener(v -> {
            // 今フェーズ最小：件数表示更新のみ（再送実装は次の段階でWorker化）
            refresh();
        });
        btnLogout.setOnClickListener(v -> {
            FoundationSession.clear();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
        });
    }

    private void refresh() {
        LoginResult r = FoundationSession.get();
        if (r == null) {
            txtUser.setText("user: (none)");
            txtCompany.setText("company: (none)");
            txtState.setText("state: (none)");
            txtLic.setText("licenses: []");
        } else {
            txtUser.setText("user: " + r.userId);
            txtCompany.setText("company: " + (r.companyId == null ? "(none)" : r.companyId));
            txtState.setText("state: " + r.foundationState.name());
            txtLic.setText("licenses: " + r.licenseCodes.toString());
        }

        OutboxDao dao = new OutboxDao(this);
        txtOutbox.setText("outbox queued=" + dao.countQueued() + " failed=" + dao.countFailed());
    }
}
