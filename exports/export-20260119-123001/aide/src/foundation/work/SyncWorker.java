package foundation.work;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import foundation.sync.SyncCoordinator;

/**
 * SyncWorker
 *
 * - バックグラウンド同期
 * - Supabase → SQLite
 */
public final class SyncWorker extends Worker {

    public SyncWorker(
            @NonNull Context context,
            @NonNull WorkerParameters params) {
        super(context, params);
    }

    @NonNull
    @Override
    public Result doWork() {
        try {
            new SyncCoordinator(getApplicationContext()).runAll();
            return Result.success();
        } catch (Exception e) {
            return Result.retry();
        }
    }
}
