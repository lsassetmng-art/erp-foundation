package com.lsam.MoneySelfManager.ui.admin;

import android.os.Bundle;
import android.widget.Switch;
import androidx.appcompat.app.AppCompatActivity;
import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.utils.AdminGuard;
import com.lsam.MoneySelfManager.repositories.OpsRepository;

public class KillSwitchActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        AdminGuard.ensureAdmin(this);
        setContentView(R.layout.activity_kill_switch);

        Switch sw = findViewById(R.id.swKill);

        sw.setOnCheckedChangeListener((v,on)->{
            new Thread(() -> {
                try {
                    OpsRepository.setKillSwitch(on);
                } catch(Exception ignore){}
            }).start();
        });
    }
}
