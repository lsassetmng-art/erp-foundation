package com.lsam.MoneySelfManager.ui.recommendation;

import java.util.ArrayList;
import java.util.List;

/**
 * READ ONLY repository.
 * Phase 9.7では「表示のみ」。
 *
 * TODO:
 *  - Supabase/PostgREST等で analytics.v_approval_recommendation_candidate を SELECT して取得する
 *  - 0件は正常（空表示）
 *  - INSERT/UPDATE/DELETEは実装禁止
 */
public class ApprovalRecommendationRepository {

    public List<ApprovalRecommendation> loadRecommendationsReadOnly() {
        // 現状DBは0件が正常。UI動作確認のために表示したい場合だけ下のダミーを有効化する。
        // 本番は空のままでOK。

        return new ArrayList<>();

        /*
        List<ApprovalRecommendation> list = new ArrayList<>();
        list.add(new ApprovalRecommendation(
                "dummy-reco-1",
                "company-uuid",
                "request-uuid",
                "ops",
                "medium",
                "Backlog/SLA/Trend を踏まえた確認提案",
                "[{\"source\":\"sla\",\"ref\":\"request-uuid\"}]",
                "medium",
                "suggested",
                "2026-02-02T00:00:00Z"
        ));
        return list;
        */
    }
}
