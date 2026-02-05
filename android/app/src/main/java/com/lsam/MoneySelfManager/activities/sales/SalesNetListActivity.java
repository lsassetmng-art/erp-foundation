package com.lsam.MoneySelfManager.activities.sales;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.adapters.SalesNetAdapter;
import com.lsam.MoneySelfManager.models.SalesNetRow;
import com.lsam.MoneySelfManager.repositories.SalesNetRepository;

import java.util.ArrayList;

public final class SalesNetListActivity extends AppCompatActivity {

    private SalesNetAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sales_net_list);

        RecyclerView rv = findViewById(R.id.recycler);
        rv.setLayoutManager(new LinearLayoutManager(this));
        adapter = new SalesNetAdapter(this::openDetail);
        rv.setAdapter(adapter);

        Button btn = findViewById(R.id.btnAlerts);
        btn.setOnClickListener(v -> startActivity(new Intent(this, SalesAlertListActivity.class)));

        load();
    }

    private void load() {
        new Thread(() -> {
            try {
                ArrayList<SalesNetRow> list = SalesNetRepository.fetchLatest(this, 100);
                runOnUiThread(() -> adapter.setItems(list));
            } catch (Exception e) {
                runOnUiThread(() -> Toast.makeText(this, String.valueOf(e.getMessage()), Toast.LENGTH_LONG).show());
            }
        }).start();
    }

    private void openDetail(SalesNetRow row) {
        Intent it = new Intent(this, SalesNetDetailActivity.class);
        it.putExtra("billing_no", row.billing_no == null ? "" : row.billing_no);
        it.putExtra("billing_date", row.billing_date == null ? "" : row.billing_date);
        it.putExtra("item_id", row.item_id);
        it.putExtra("net_amount", row.net_amount);
        it.putExtra("gross_amount", row.gross_amount);
        it.putExtra("return_amount", row.return_amount);
        it.putExtra("unit_price", row.unit_price);
        it.putExtra("billed_qty", row.billed_qty);
        it.putExtra("returned_qty", row.returned_qty);
        it.putExtra("net_qty", row.net_qty);
        startActivity(it);
    }
}
