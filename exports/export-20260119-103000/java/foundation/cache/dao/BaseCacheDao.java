package foundation.cache.dao;

import android.database.sqlite.SQLiteDatabase;
import foundation.cache.db.CacheDatabaseHelper;
import android.content.Context;

/**
 * BaseCacheDao
 *
 * - Read-only アクセス専用
 */
public abstract class BaseCacheDao {

    protected final SQLiteDatabase db;

    protected BaseCacheDao(Context context) {
        this.db = new CacheDatabaseHelper(context).getReadableDatabase();
    }
}
