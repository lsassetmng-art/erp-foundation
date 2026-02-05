package com.lsam.MoneySelfManager.activities.sales;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.adapters.AlertAdapter;
import com.lsam.MoneySelfManager.models.AlertRow;
import com.lsam.MoneySelfManager.repositories.AlertRepository;

import java.util.ArrayList;

public final class SalesAlertListActivity extends AppCompatActivity {

    private AlertAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sales_alert_list);

        RecyclerView rv = findViewById(R.id.recycler);
        rv.setLayoutManager(new LinearLayoutManager(this));
        adapter = new AlertAdapter(this::open);
        rv.setAdapter(adapter);

        load();
    }

    private void load() {
        new Thread(() -> {
            try {
                ArrayList<AlertRow> list = AlertRepository.fetchAll(this);
                runOnUiThread(() -> adapter.setItems(list));
            } catch (Exception e) {
                runOnUiThread(() -> Toast.makeText(this, String.valueOf(e.getMessage()), Toast.LENGTH_LONG).show());
            }
        }).start();
    }

    private void open(AlertRow row) {
        Intent it = new Intent(this, SalesAlertDetailActivity.class);
        it.putExtra("type", row.type == null ? "" : row.type);
        it.putExtra("body", row.body == null ? "" : row.body);
        startActivity(it);
    }
}
