package com.lsam.MoneySelfManager.ui.recommendation;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.lsam.MoneySelfManager.R;

import java.util.List;

public class ApprovalRecommendationListActivity extends AppCompatActivity {

    // 固定注意文（正本）
    private static final String NOTICE_LINE1 = "これは確認提案です。最終判断は承認者が行います。";
    private static final String NOTICE_LINE2 = "本表示は承認・却下を自動で行いません。";

    private ApprovalRecommendationRepository repo;
    private ApprovalRecommendationAdapter adapter;

    private TextView tvEmpty;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_approval_recommendation_list);

        TextView tvNotice = findViewById(R.id.tvNotice);
        tvNotice.setText(NOTICE_LINE1 + "\n" + NOTICE_LINE2);

        tvEmpty = findViewById(R.id.tvEmptyState);

        RecyclerView rv = findViewById(R.id.recycler);
        rv.setLayoutManager(new LinearLayoutManager(this));

        adapter = new ApprovalRecommendationAdapter(item -> {
            Intent it = new Intent(this, ApprovalRecommendationDetailActivity.class);
            it.putExtra(ApprovalRecommendationDetailActivity.EXTRA_ITEM, item);
            startActivity(it);
        });
        rv.setAdapter(adapter);

        repo = new ApprovalRecommendationRepository();
        reloadReadOnly();
    }

    private void reloadReadOnly() {
        List<ApprovalRecommendation> list = repo.loadRecommendationsReadOnly();
        adapter.submit(list);

        boolean empty = (list == null || list.isEmpty());
        tvEmpty.setVisibility(empty ? View.VISIBLE : View.GONE);
    }
}
