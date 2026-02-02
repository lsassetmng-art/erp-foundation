package com.lsam.MoneySelfManager.foundation.ui;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.lsam.MoneySelfManager.R;

public final class FoundationMasterMenuActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_foundation_master_menu);

        TextView t = findViewById(R.id.txtMasterMenu);
        t.setText("Foundation Masters (minimal)\n\n" +
                "- company\n" +
                "- license\n" +
                "- role/permission\n" +
                "- foundation_config\n\n" +
                "※ 今フェーズは UI 作り込みしない（SQL/RPCで運用も可）");
    }
}
