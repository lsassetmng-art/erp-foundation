package com.lsam.MoneySelfManager.activities.admin;

import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.network.SupabaseRpc;

import org.json.JSONObject;

public class OpsDashboardActivity extends AppCompatActivity {

    private TextView txtSummary;

    // TODO: あなたの company_id を入れる（SessionManager等から取るのが理想）
    private String companyId = "8f3c2e6a-9c1b-4c7a-a5d2-1c8c4b7f9e12";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ops_dashboard);

        txtSummary = findViewById(R.id.txtSummary);
        Button btnRefresh = findViewById(R.id.btnRefresh);
        Button btnApprovals = findViewById(R.id.btnApprovals);

        btnRefresh.setOnClickListener(v -> loadSummary());
        btnApprovals.setOnClickListener(v -> ApprovalListActivity.start(this));

        loadSummary();
    }

    private void loadSummary() {
        new Thread(() -> {
            try {
                JSONObject body = new JSONObject();
                body.put("p_company_id", companyId);
                String res = SupabaseRpc.postJson("/rest/v1/rpc/api_dashboard_summary", body);

                runOnUiThread(() -> txtSummary.setText(res));
            } catch (Exception e) {
                runOnUiThread(() -> Toast.makeText(this, e.getMessage(), Toast.LENGTH_LONG).show());
            }
        }).start();
    }
}
