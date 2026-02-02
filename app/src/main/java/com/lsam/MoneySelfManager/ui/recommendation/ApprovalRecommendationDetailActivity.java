package com.lsam.MoneySelfManager.ui.recommendation;

import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.lsam.MoneySelfManager.R;

public class ApprovalRecommendationDetailActivity extends AppCompatActivity {

    public static final String EXTRA_ITEM = "extra_item";

    // 固定注意文（正本）
    private static final String NOTICE_LINE1 = "これは確認提案です。最終判断は承認者が行います。";
    private static final String NOTICE_LINE2 = "本表示は承認・却下を自動で行いません。";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_approval_recommendation_detail);

        TextView tvNotice = findViewById(R.id.tvNotice);
        tvNotice.setText(NOTICE_LINE1 + "\n" + NOTICE_LINE2);

        ApprovalRecommendation item = null;
        Object o = getIntent().getSerializableExtra(EXTRA_ITEM);
        if (o instanceof ApprovalRecommendation) item = (ApprovalRecommendation) o;

        TextView tvRequestId = findViewById(R.id.tvRequestId);
        TextView tvDomain = findViewById(R.id.tvDomain);
        TextView tvSeverity = findViewById(R.id.tvSeverity);
        TextView tvConfidence = findViewById(R.id.tvConfidenceBand);
        TextView tvGeneratedAt = findViewById(R.id.tvGeneratedAt);

        TextView tvRationale = findViewById(R.id.tvRationale);
        TextView tvEvidenceRefs = findViewById(R.id.tvEvidenceRefs);
        TextView tvSuggestedAction = findViewById(R.id.tvSuggestedAction);

        if (item == null) {
            tvRequestId.setText("");
            tvDomain.setText("");
            tvSeverity.setText("");
            tvConfidence.setText("");
            tvGeneratedAt.setText("");
            tvRationale.setText("");
            tvEvidenceRefs.setText("");
            tvSuggestedAction.setText("");
            return;
        }

        tvRequestId.setText(item.requestId == null ? "" : item.requestId);
        tvDomain.setText(item.domain == null ? "" : item.domain);
        tvSeverity.setText(item.severity == null ? "" : item.severity);
        tvConfidence.setText(item.confidenceBand == null ? "" : item.confidenceBand);
        tvGeneratedAt.setText(item.generatedAt == null ? "" : item.generatedAt);

        tvRationale.setText(item.rationale == null ? "" : item.rationale);
        tvEvidenceRefs.setText(item.evidenceRefsJson == null ? "" : item.evidenceRefsJson);
        tvSuggestedAction.setText(item.suggestedAction == null ? "" : item.suggestedAction);
    }
}
