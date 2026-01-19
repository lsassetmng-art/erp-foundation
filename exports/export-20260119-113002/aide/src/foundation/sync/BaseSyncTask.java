package foundation.sync;

import android.content.Context;

/**
 * BaseSyncTask
 *
 * - 同期処理の基底クラス
 * - Supabase → SQLite のみ
 * - company_id は扱わない
 */
public abstract class BaseSyncTask {

    protected final Context context;

    protected BaseSyncTask(Context context) {
        this.context = context;
    }

    /**
     * 実同期処理
     */
    public abstract void run() throws Exception;
}
