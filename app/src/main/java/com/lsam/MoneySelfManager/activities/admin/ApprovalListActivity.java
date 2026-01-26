package com.lsam.MoneySelfManager.activities.admin;

import android.app.AlertDialog;
import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.lsam.MoneySelfManager.repositories.ApprovalRepository;
import com.lsam.MoneySelfManager.utils.AdminGuard;
import org.json.*;
import java.util.*;

public class ApprovalListActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_approval_list);
        AdminGuard.require(this, "approval.read");

        ListView list = findViewById(R.id.listApproval);
        ArrayList<JSONObject> rows = new ArrayList<>();
        ArrayAdapter<String> ad = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, new ArrayList<>());
        list.setAdapter(ad);

        String companyId = getSharedPreferences("session", MODE_PRIVATE).getString("company_id", "");

        new Thread(() -> {
            try {
                JSONArray arr = new JSONArray(ApprovalRepository.listPending(companyId));
                rows.clear(); ad.clear();
                for (int i=0;i<arr.length();i++){
                    JSONObject o = arr.getJSONObject(i);
                    rows.add(o);
                    ad.add("#"+o.getLong("approval_request_id")+" "+o.optString("title"));
                }
                runOnUiThread(ad::notifyDataSetChanged);
            } catch (Exception e) {}
        }).start();

        list.setOnItemClickListener((p,v,pos,id)->{
            JSONObject o = rows.get(pos);
            long aid = o.optLong("approval_request_id");
            String title = o.optString("title");
            String body  = o.optString("body");

            EditText reason = new EditText(this);
            reason.setHint("Reject理由（任意）");

            new AlertDialog.Builder(this)
                .setTitle(title)
                .setMessage(body)
                .setView(reason)
                .setPositiveButton("Approve",(d,w)->{
                    new Thread(()->{
                        try { ApprovalRepository.approve(aid,"admin"); finish(); startActivity(getIntent()); }
                        catch(Exception e){}
                    }).start();
                })
                .setNegativeButton("Reject",(d,w)->{
                    new Thread(()->{
                        try { ApprovalRepository.reject(aid,"admin",reason.getText().toString()); finish(); startActivity(getIntent()); }
                        catch(Exception e){}
                    }).start();
                })
                .show();
        });
    }
}
