package com.example.MoneySelfManager.activities.governance;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;

import androidx.appcompat.app.AppCompatActivity;

public class GovernanceWebViewActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView wv = new WebView(this);
        setContentView(wv);

        WebSettings s = wv.getSettings();
        s.setJavaScriptEnabled(false);
        s.setDomStorageEnabled(false);

        // Termux端末ローカルUI（同一端末内）を表示
        // 例: http://127.0.0.1:8765/
        wv.loadUrl("http://127.0.0.1:8765/");
    }
}
