package foundation.sync;

import android.content.Context;
import java.util.ArrayList;
import java.util.List;

/**
 * SyncCoordinator
 *
 * - 複数 SyncTask を順序制御
 * - UI / ViewModel からはこれだけ呼ぶ
 */
public final class SyncCoordinator {

    private final List<BaseSyncTask> tasks = new ArrayList<>();

    public SyncCoordinator(Context context) {
        // 登録はここで
        tasks.add(new OrderSyncTask(context));
    }

    public void runAll() {
        for (BaseSyncTask task : tasks) {
            try {
                task.run();
            } catch (Exception e) {
                // ログ出力のみ（同期は失敗してもアプリは落とさない）
                e.printStackTrace();
            }
        }
    }
}
