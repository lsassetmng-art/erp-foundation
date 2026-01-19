package foundation.sync;

import android.content.Context;

/**
 * OrderSyncTask
 *
 * - 注文データ同期（雛形）
 * - 実装は後から差し込み
 */
public final class OrderSyncTask extends BaseSyncTask {

    public OrderSyncTask(Context context) {
        super(context);
    }

    @Override
    public void run() throws Exception {
        // TODO:
        // 1. Supabase RPC で注文一覧取得
        // 2. SQLite キャッシュを更新
        // ※ company_id は一切扱わない
    }
}
