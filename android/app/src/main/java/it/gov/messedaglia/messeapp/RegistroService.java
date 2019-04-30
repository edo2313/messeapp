package it.gov.messedaglia.messeapp;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;

public class RegistroService extends Service {
    private final static String TAG = "RegistroService";

    private final static String APIKEY = "Tg1NWEwNGIgIC0K";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        new Thread(this::run).start();
        return super.onStartCommand(intent, flags, startId);
    }

    private void run (){
        SharedPreferences sp = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String username = sp.getString("flutter.pref_CVVS_UNAME", null);
        String password = sp.getString("flutter.pref_CVVS_PWORD", null);
        if (username == null || password == null) return;
        try {
            String token = login(username, password);
            String etag = sp.getString("marks_etag", null);
            if (connect(token, etag, "https://web.spaggiari.eu/rest/v1/students/"+username.substring(1, username.length()-1)+"/grades2")){
                /*NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
                Notification n = new Notification();
                notificationManager.notify(1, n);*/
                // TODO: notificare la presenza di nuovi voti
            }

        } catch (IOException e){
            Log.println(Log.ASSERT, TAG, e.getMessage());
        } catch (JSONException e){
            Log.println(Log.ASSERT, TAG, e.getMessage());
        }
        Log.println(Log.ASSERT, TAG, "stop running...");
    }

    private String login (final String username, final String password) throws IOException, JSONException {
        URL url = new URL("https://web.spaggiari.eu/rest/v1/auth/login");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        String data = "{\"ident\":null,\"pass\":\""+password+"\",\"uid\":\""+username+"\"}";
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Z-Dev-Apikey", APIKEY);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("User-Agent", "CVVS/std/1.7.9 Android/6.0)");
        OutputStreamWriter osw = new OutputStreamWriter(connection.getOutputStream());
        osw.write(data);
        osw.flush();
        osw.close();
        connection.connect();
        if (connection.getResponseCode() != 200) return null;
        StringBuilder contentBuilder = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String str;
        while ((str = reader.readLine()) != null) contentBuilder.append(str).append('\n');
        JSONObject object = new JSONObject(contentBuilder.toString());
        return object.getString("token");
    }

    private boolean connect (final String token, final String etag, final String link) throws IOException{
        if (etag == null) return false;
        URL url = new URL(link);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestProperty("Z-Dev-Apikey", APIKEY);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("User-Agent", "CVVS/std/1.7.9 Android/6.0)");
        connection.setRequestProperty("Z-Auth-Token", token);
        connection.setRequestProperty("Z-If-None-Match", etag);
        connection.connect();
        return connection.getResponseCode() == 200;
    }
}
