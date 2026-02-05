package com.lsam.MoneySelfManager.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.lsam.MoneySelfManager.R;
import com.lsam.MoneySelfManager.models.SalesNetRow;

import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Locale;

public final class SalesNetAdapter extends RecyclerView.Adapter<SalesNetAdapter.VH> {

    public interface OnClick {
        void onClick(SalesNetRow row);
    }

    private final ArrayList<SalesNetRow> items = new ArrayList<>();
    private final OnClick onClick;
    private final NumberFormat nf = NumberFormat.getNumberInstance(Locale.JAPAN);

    public SalesNetAdapter(OnClick onClick) {
        this.onClick = onClick;
        nf.setMaximumFractionDigits(2);
    }

    public void setItems(ArrayList<SalesNetRow> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_sales_net, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH h, int pos) {
        SalesNetRow r = items.get(pos);
        h.txt1.setText((r.billing_date == null ? "" : r.billing_date) + "  " + (r.billing_no == null ? "" : r.billing_no));
        h.txt2.setText("item=" + r.item_id + " net=" + nf.format(r.net_amount) + " qty=" + nf.format(r.net_qty));
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
