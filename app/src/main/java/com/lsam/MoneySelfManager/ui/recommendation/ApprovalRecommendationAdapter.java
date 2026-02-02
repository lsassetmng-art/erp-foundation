package com.lsam.MoneySelfManager.ui.recommendation;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.lsam.MoneySelfManager.R;

import java.util.ArrayList;
import java.util.List;

public class ApprovalRecommendationAdapter extends RecyclerView.Adapter<ApprovalRecommendationAdapter.VH> {

    public interface OnItemClickListener {
        void onClick(ApprovalRecommendation item);
    }

    private final List<ApprovalRecommendation> items = new ArrayList<>();
    private final OnItemClickListener listener;

    public ApprovalRecommendationAdapter(OnItemClickListener listener) {
        this.listener = listener;
    }

    public void submit(List<ApprovalRecommendation> newItems) {
        items.clear();
        if (newItems != null) items.addAll(newItems);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_approval_recommendation, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH h, int position) {
        final ApprovalRecommendation it = items.get(position);

        h.tvRequestId.setText(it.requestId == null ? "" : it.requestId);
        h.tvDomain.setText(it.domain == null ? "" : it.domain);
        h.tvSeverity.setText(it.severity == null ? "" : it.severity);

        // confidence_band は数値化しない。文字列のみ（色付け等は必要なら後で）
        h.tvConfidence.setText(it.confidenceBand == null ? "" : it.confidenceBand);

        h.tvGeneratedAt.setText(it.generatedAt == null ? "" : it.generatedAt);

        h.itemView.setOnClickListener(v -> {
            if (listener != null) listener.onClick(it);
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        TextView tvRequestId;
        TextView tvDomain;
        TextView tvSeverity;
        TextView tvConfidence;
        TextView tvGeneratedAt;

        VH(@NonNull View itemView) {
            super(itemView);
            tvRequestId = itemView.findViewById(R.id.tvRequestId);
            tvDomain = itemView.findViewById(R.id.tvDomain);
            tvSeverity = itemView.findViewById(R.id.tvSeverity);
            tvConfidence = itemView.findViewById(R.id.tvConfidenceBand);
            tvGeneratedAt = itemView.findViewById(R.id.tvGeneratedAt);
        }
    }
}
