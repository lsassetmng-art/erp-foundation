package com.lsam.erp.approval;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class ApprovalWebViewActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        WebView webView = new WebView(this);
        setContentView(webView);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);

        webView.setWebViewClient(new WebViewClient());

        // 承認UI（Web版）をそのまま表示
        // 通知URL / DeepLink から request_id を付与してもOK
        webView.loadUrl("https://YOUR-DOMAIN/approval.html");
    }
}
