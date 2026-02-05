package com.lsam.MoneySelfManager.activities.sales;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.lsam.MoneySelfManager.R;

public final class SalesAlertDetailActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sales_alert_detail);

        String type = getIntent().getStringExtra("type");
        String body = getIntent().getStringExtra("body");

        ((TextView)findViewById(R.id.txtType)).setText(type == null ? "" : type);
        ((TextView)findViewById(R.id.txtBody)).setText(body == null ? "" : body);
    }
}
