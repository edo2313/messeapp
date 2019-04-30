package it.gov.messedaglia.messeapp;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private final static String TAG = "BootReceiver";

    @Override
    public void onReceive(Context context, Intent bootIntent) {
        // TODO: far partire il service anche all'apertura della app
        Log.i(TAG, "Broadcast received, action: "+bootIntent.getAction());
        if (Intent.ACTION_BOOT_COMPLETED.equals(bootIntent.getAction())){
            AlarmManager alarm = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            Intent intent = new Intent(context, RegistroService.class);
            PendingIntent pendingIntent = PendingIntent.getService(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
            alarm.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), AlarmManager.INTERVAL_HOUR, pendingIntent);
        }
    }
}
