package com.lsam.MoneySelfManager.ui.recommendation;

import java.io.Serializable;

public class ApprovalRecommendation implements Serializable {
    public final String recommendationId;
    public final String companyId;
    public final String requestId;
    public final String domain;
    public final String severity;
    public final String rationale;
    public final String evidenceRefsJson; // jsonb相当を表示用に文字列で保持
    public final String confidenceBand;   // low / medium / high
    public final String suggestedAction;  // suggested / notified
    public final String generatedAt;      // ISO文字列など

    public ApprovalRecommendation(
            String recommendationId,
            String companyId,
            String requestId,
            String domain,
            String severity,
            String rationale,
            String evidenceRefsJson,
            String confidenceBand,
            String suggestedAction,
            String generatedAt
    ) {
        this.recommendationId = recommendationId;
        this.companyId = companyId;
        this.requestId = requestId;
        this.domain = domain;
        this.severity = severity;
        this.rationale = rationale;
        this.evidenceRefsJson = evidenceRefsJson;
        this.confidenceBand = confidenceBand;
        this.suggestedAction = suggestedAction;
        this.generatedAt = generatedAt;
    }
}
