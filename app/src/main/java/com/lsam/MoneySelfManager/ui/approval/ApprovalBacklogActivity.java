package com.lsam.MoneySelfManager.ui.approval;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;
import com.lsam.MoneySelfManager.R;
import java.util.List;

public class ApprovalBacklogActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_approval_backlog);

        RecyclerView rv = findViewById(R.id.recycler);
        TextView empty = findViewById(R.id.empty_text);

        List<ApprovalBacklogRow> rows = ApprovalBacklogRepository.load(this);
        if (rows == null || rows.isEmpty()) {
            empty.setVisibility(View.VISIBLE);
            empty.setText(R.string.approval_empty);
            rv.setVisibility(View.GONE);
        } else {
            empty.setVisibility(View.GONE);
            rv.setVisibility(View.VISIBLE);
            rv.setAdapter(new ApprovalBacklogAdapter(rows));
        }
    }
}
