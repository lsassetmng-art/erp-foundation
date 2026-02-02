package com.lsam.MoneySelfManager.ui.admin;

import android.os.Bundle;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.utils.AdminGuard;
import com.lsam.MoneySelfManager.repositories.AuditRepository;

public class AlertListActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        AdminGuard.ensureAdmin(this);
        setContentView(R.layout.activity_alert_list);

        TextView tv = findViewById(R.id.txtAlert);

        String companyId = getSharedPreferences("session", MODE_PRIVATE)
            .getString("company_id","");

        new Thread(() -> {
            try{
                String res = AuditRepository.listRecent(companyId);
                runOnUiThread(() -> tv.setText(res));
            }catch(Exception e){
                runOnUiThread(() -> tv.setText("ERR:"+e.getMessage()));
            }
        }).start();
    }
}
