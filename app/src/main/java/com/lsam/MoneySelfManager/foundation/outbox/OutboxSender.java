package com.lsam.MoneySelfManager.foundation.outbox;

import com.lsam.MoneySelfManager.foundation.network.SupabaseMiniHttp;

import org.json.JSONObject;

public final class OutboxSender {

    public static boolean sendOneToFoundationOutboxEvent(String accessToken, String eventType, String idempotencyKey, String payloadJson) {
        try {
            JSONObject payload = new JSONObject(payloadJson);

            JSONObject body = new JSONObject();
            body.put("event_type", eventType);
            if (idempotencyKey != null) body.put("idempotency_key", idempotencyKey);
            body.put("payload", payload);

            // REST insert: /rest/v1/foundation.outbox_event
            JSONObject res = SupabaseMiniHttp.postJson("/rest/v1/outbox_event", body, accessToken);
            int code = res.getInt("_http_code");
            return (code >= 200 && code < 300);

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
