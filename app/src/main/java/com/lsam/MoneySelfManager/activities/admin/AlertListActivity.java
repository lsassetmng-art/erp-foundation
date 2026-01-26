package com.lsam.MoneySelfManager.activities.admin;

import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.lsam.MoneySelfManager.repositories.AuditRepository;
import com.lsam.MoneySelfManager.utils.AdminGuard;
import org.json.*;
import java.util.*;

public class AlertListActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_alert_list);
        AdminGuard.require(this,"alert.read");

        ListView list = findViewById(R.id.listAlert);
        ArrayAdapter<String> ad = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, new ArrayList<>());
        list.setAdapter(ad);

        String companyId = getSharedPreferences("session", MODE_PRIVATE).getString("company_id","");

        new Thread(()->{
            try{
                JSONArray arr = new JSONArray(AuditRepository.listRecent(companyId));
                ad.clear();
                for(int i=0;i<arr.length();i++){
                    JSONObject o=arr.getJSONObject(i);
                    ad.add(o.optString("severity")+" "+o.optString("event_type")+" "+o.optString("created_at"));
                }
                runOnUiThread(ad::notifyDataSetChanged);
            }catch(Exception e){}
        }).start();
    }
}
