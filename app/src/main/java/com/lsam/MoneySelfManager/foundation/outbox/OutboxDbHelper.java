package com.lsam.MoneySelfManager.foundation.outbox;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public final class OutboxDbHelper extends SQLiteOpenHelper {

    private static final String DB_NAME = "foundation_outbox.db";
    private static final int DB_VER = 1;

    public OutboxDbHelper(Context ctx) {
        super(ctx, DB_NAME, null, DB_VER);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("create table if not exists outbox (" +
                "outbox_id text primary key," +
                "event_type text not null," +
                "idempotency_key text," +
                "payload_json text not null," +
                "status text not null default 'queued'," + // queued/sent/failed
                "retry_count integer not null default 0," +
                "last_error text," +
                "created_at integer not null" +
                ")");
        db.execSQL("create index if not exists ix_outbox_status on outbox(status)");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // 最小：将来migration
    }
}
