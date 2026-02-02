package com.lsam.MoneySelfManager.ui.main;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.ui.admin.AdminMenuActivity;

public class MainActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_main);

        findViewById(R.id.btnAdmin).setOnClickListener(v ->
            startActivity(new Intent(this, AdminMenuActivity.class))
        );
    }
}
