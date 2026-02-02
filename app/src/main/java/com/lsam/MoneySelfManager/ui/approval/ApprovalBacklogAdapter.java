package com.lsam.MoneySelfManager.ui.approval;

import android.graphics.Color;
import android.view.View;
import android.view.ViewGroup;
import android.view.LayoutInflater;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.lsam.MoneySelfManager.R;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class ApprovalBacklogAdapter extends RecyclerView.Adapter<ApprovalBacklogAdapter.VH> {

    private final List<ApprovalBacklogRow> rows;

    public ApprovalBacklogAdapter(List<ApprovalBacklogRow> rows) {
        this.rows = rows;
    }

    static class VH extends RecyclerView.ViewHolder {
        View bar;
        TextView title, sub, elapsed;
        VH(View v) {
            super(v);
            bar = v.findViewById(R.id.severity_bar);
            title = v.findViewById(R.id.txt_title);
            sub = v.findViewById(R.id.txt_sub);
            elapsed = v.findViewById(R.id.txt_elapsed);
        }
    }

    @Override public VH onCreateViewHolder(ViewGroup p, int t) {
        View v = LayoutInflater.from(p.getContext())
                .inflate(R.layout.row_approval_backlog, p, false);
        return new VH(v);
    }

    @Override public void onBindViewHolder(VH h, int i) {
        ApprovalBacklogRow r = rows.get(i);
        h.title.setText(r.domain + " / " + r.entityType);
        h.sub.setText("severity: " + r.severity);

        // severity color (display only)
        h.bar.setBackgroundColor(colorOf(r.severity));

        // elapsed hours (display only)
        long hours = TimeUnit.MILLISECONDS.toHours(
                Math.max(0, System.currentTimeMillis() - r.detectedAt)
        );
        h.elapsed.setText(h.itemView.getContext()
                .getString(R.string.elapsed_hours, hours));
    }

    @Override public int getItemCount() { return rows.size(); }

    private int colorOf(String s) {
        if ("high".equalsIgnoreCase(s)) return Color.parseColor("#E53935");
        if ("medium".equalsIgnoreCase(s)) return Color.parseColor("#FB8C00");
        return Color.parseColor("#BDBDBD");
    }
}
