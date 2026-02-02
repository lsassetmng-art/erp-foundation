package com.lsam.MoneySelfManager.foundation.outbox;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import java.util.UUID;

public final class OutboxDao implements OutboxPort {

    private final OutboxDbHelper helper;

    public OutboxDao(Context ctx) {
        this.helper = new OutboxDbHelper(ctx);
    }

    @Override
    public String enqueue(String eventType, String idempotencyKey, String payloadJson) {
        String id = UUID.randomUUID().toString();
        SQLiteDatabase db = helper.getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put("outbox_id", id);
        cv.put("event_type", eventType);
        cv.put("idempotency_key", idempotencyKey);
        cv.put("payload_json", payloadJson);
        cv.put("status", "queued");
        cv.put("retry_count", 0);
        cv.put("created_at", System.currentTimeMillis());
        db.insert("outbox", null, cv);
        return id;
    }

    @Override
    public void markSuccess(String outboxId) {
        SQLiteDatabase db = helper.getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put("status", "sent");
        cv.put("last_error", (String) null);
        db.update("outbox", cv, "outbox_id=?", new String[]{outboxId});
    }

    @Override
    public void markFailure(String outboxId, String reason) {
        SQLiteDatabase db = helper.getWritableDatabase();
        db.execSQL("update outbox set status='failed', retry_count=retry_count+1, last_error=? where outbox_id=?",
                new Object[]{reason, outboxId});
    }

    @Override
    public int countQueued() {
        return countByStatus("queued");
    }

    @Override
    public int countFailed() {
        return countByStatus("failed");
    }

    private int countByStatus(String st) {
        SQLiteDatabase db = helper.getReadableDatabase();
        Cursor c = db.rawQuery("select count(*) from outbox where status=?", new String[]{st});
        try {
            if (c.moveToFirst()) return c.getInt(0);
            return 0;
        } finally {
            c.close();
        }
    }
}
