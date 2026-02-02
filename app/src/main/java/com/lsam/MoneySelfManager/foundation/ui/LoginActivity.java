package com.lsam.MoneySelfManager.foundation.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.foundation.auth.AuthPort;
import com.lsam.MoneySelfManager.foundation.auth.AuthRepository;
import com.lsam.MoneySelfManager.foundation.config.FoundationConfigStore;
import com.lsam.MoneySelfManager.foundation.model.LoginResult;

public final class LoginActivity extends Activity {

    private EditText edtEmail;
    private EditText edtPass;
    private Button btnLogin;

    private AuthPort auth;
    private FoundationConfigStore cfg;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_foundation_login);

        edtEmail = findViewById(R.id.edtEmail);
        edtPass  = findViewById(R.id.edtPassword);
        btnLogin = findViewById(R.id.btnLogin);

        auth = new AuthRepository();
        cfg  = new FoundationConfigStore(this);

        btnLogin.setOnClickListener(v -> doLogin());
    }

    private void doLogin() {
        String email = edtEmail.getText().toString().trim();
        String pass  = edtPass.getText().toString();

        if (email.isEmpty() || pass.isEmpty()) {
            Toast.makeText(this, "email/password required", Toast.LENGTH_SHORT).show();
            return;
        }

        // 簡易：UIスレッドで実行（まず動作優先）。後でThread化してOK。
        LoginResult r = auth.login(email, pass);
        if (!r.success) {
            Toast.makeText(this, r.errorMessage, Toast.LENGTH_LONG).show();
            return;
        }

        FoundationSession.set(r);

        // PostLoginHandler がある場合は呼ぶ（今フェーズは未実装でもOK）
        // ない場合は設定キーで分岐（デフォルト FOUNDATION_HOME）
        String dest = cfg.getString("post_login_destination", "FOUNDATION_HOME");
        if ("FOUNDATION_HOME".equals(dest)) {
            startActivity(new Intent(this, FoundationHomeActivity.class));
            finish();
            return;
        }

        // それ以外は暫定でFoundationHomeへ
        startActivity(new Intent(this, FoundationHomeActivity.class));
        finish();
    }
}
