package com.lsam.MoneySelfManager.foundation.outbox;

public interface OutboxPort {
    String enqueue(String eventType, String idempotencyKey, String payloadJson);
    void markSuccess(String outboxId);
    void markFailure(String outboxId, String reason);
    int countQueued();
    int countFailed();
}
