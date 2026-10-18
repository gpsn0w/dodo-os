package os.dodo.bootcheck;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.provider.Settings;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context ctx, Intent intent) {
        if (intent == null || !Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            return;
        }
        try {
            // Показвай проверката само след като setup wizard-ът е завършил —
            // иначе изскача върху първоначалната настройка при чист flash.
            int done = Settings.Secure.getInt(ctx.getContentResolver(),
                    Settings.Secure.USER_SETUP_COMPLETE, 0);
            if (done != 1) {
                return;
            }
            Intent i = new Intent(ctx, CheckActivity.class);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            ctx.startActivity(i);
        } catch (Throwable t) {
            // не трябва да чупим boot при никакви обстоятелства
        }
    }
}
