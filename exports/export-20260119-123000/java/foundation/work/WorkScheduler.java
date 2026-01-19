package foundation.work;

import android.content.Context;
import androidx.work.Constraints;
import androidx.work.NetworkType;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import java.util.concurrent.TimeUnit;

/**
 * WorkScheduler
 *
 * - アプリ起動時に一度だけ登録
 */
public final class WorkScheduler {

    public static void schedule(Context context) {
        Constraints constraints =
                new Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build();

        PeriodicWorkRequest request =
                new PeriodicWorkRequest.Builder(
                        SyncWorker.class,
                        6, TimeUnit.HOURS
                )
                .setConstraints(constraints)
                .build();

        WorkManager.getInstance(context)
                .enqueue(request);
    }
}
