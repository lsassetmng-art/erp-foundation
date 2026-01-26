package com.lsam.MoneySelfManager.activities.admin;

import android.os.Bundle;
import android.widget.Switch;
import androidx.appcompat.app.AppCompatActivity;
import com.lsam.MoneySelfManager.network.SupabaseHttp;
import com.lsam.MoneySelfManager.utils.AdminGuard;
import org.json.*;

public class KillSwitchActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_kill_switch);
        AdminGuard.require(this, "kill_switch.read");

        Switch sw = findViewById(R.id.swKill);
        String companyId = getSharedPreferences("session", MODE_PRIVATE).getString("company_id","");

        new Thread(()->{
            try{
                JSONObject a=new JSONObject(); a.put("p_company_id",companyId);
                JSONArray r=new JSONArray(SupabaseHttp.rpc("ops.get_kill_switch",a));
                boolean on = r.length()>0 && r.getJSONObject(0).getBoolean("is_on");
                runOnUiThread(()->sw.setChecked(on));
            }catch(Exception e){}
        }).start();

        sw.setOnCheckedChangeListener((b1,on)->{
            AdminGuard.require(this,"kill_switch.set");
            new Thread(()->{
                try{
                    JSONObject a=new JSONObject();
                    a.put("p_company_id",companyId);
                    a.put("p_is_on",on);
                    a.put("p_reason","admin toggle");
                    SupabaseHttp.rpc("ops.set_kill_switch",a);
                }catch(Exception e){}
            }).start();
        });
    }
}
