package it.gov.messedaglia.messeapp;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.webkit.PermissionRequest;

import java.security.Permission;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private MethodChannel.Result channelResult;

    private Activity getActivity() {
        return this;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        Intent intent = new Intent(this, RegistroService.class);
        startService(intent);

        new MethodChannel(getFlutterView(), "plugins.ly.com/permission").setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
                        channelResult = result;
                        switch (call.method) {
                            case "requestSinglePermission":
                                if (ContextCompat.checkSelfPermission(getActivity(), convertPermission((String) call.argument("permissionName"))) == PackageManager.PERMISSION_GRANTED) {
                                    result.success(0);
                                    break;
                                }
                                ActivityCompat.requestPermissions(getActivity(), new String[]{convertPermission((String) call.argument("permissionName"))}, 1);
                                break;
                        }
                    }
                });
    }


    private String convertPermission (String name){
        switch (name) {
            case "Storage": return Manifest.permission.WRITE_EXTERNAL_STORAGE;
            default: return "";
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED)
                    channelResult.success(0);
                else channelResult.success(1);
        }
    }
}
