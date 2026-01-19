package foundation.cache.dao;

import android.content.Context;
import android.database.Cursor;

/**
 * OrderCacheDao
 *
 * - 注文情報キャッシュ（参照専用）
 */
public final class OrderCacheDao extends BaseCacheDao {

    public OrderCacheDao(Context context) {
        super(context);
    }

    public Cursor findAll() {
        return db.rawQuery(
                "SELECT * FROM orders_cache",
                null
        );
    }
}
