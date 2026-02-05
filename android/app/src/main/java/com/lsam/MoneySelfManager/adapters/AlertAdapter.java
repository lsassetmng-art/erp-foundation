package com.lsam.MoneySelfManager.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.models.AlertRow;

import java.util.ArrayList;

public final class AlertAdapter extends RecyclerView.Adapter<AlertAdapter.VH> {

    public interface OnClick {
        void onClick(AlertRow row);
    }

    private final ArrayList<AlertRow> items = new ArrayList<>();
    private final OnClick onClick;

    public AlertAdapter(OnClick onClick) {
        this.onClick = onClick;
    }

    public void setItems(ArrayList<AlertRow> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_alert, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH h, int pos) {
        AlertRow r = items.get(pos);
        h.txt1.setText(r.type == null ? "" : r.type);
        h.txt2.setText(r.body == null ? "" : r.body);
        h.itemView.setOnClickListener(v -> { if (onClick != null) onClick.onClick(r); });
    }

    @Override
    public int getItemCount() { return items.size(); }

    static final class VH extends RecyclerView.ViewHolder {
        final TextView txt1;
        final TextView txt2;
        VH(View v) {
            super(v);
            txt1 = v.findViewById(R.id.txtRow1);
            txt2 = v.findViewById(R.id.txtRow2);
        }
    }
}
