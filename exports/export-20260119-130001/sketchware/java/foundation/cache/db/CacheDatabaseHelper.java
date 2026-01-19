package foundation.cache.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

/**
 * CacheDatabaseHelper
 *
 * - SQLite はキャッシュ用途のみ
 * - 書き込みは同期処理のみが担当
 */
public final class CacheDatabaseHelper extends SQLiteOpenHelper {

    private static final String DB_NAME = "erp_cache.db";
    private static final int DB_VERSION = 1;

    public CacheDatabaseHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // 初期は空（必要なテーブルは後から追加）
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // キャッシュなので破棄OK
    }
}
