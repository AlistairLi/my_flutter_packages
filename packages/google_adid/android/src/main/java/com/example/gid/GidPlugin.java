package com.example.gid;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;

import java.io.IOException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * GidPlugin
 */
public class GidPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "gid");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("getGid")) {
            try {
                new Thread(() -> {
                    try {
                        result.success(createJson(AdvertisingIdClient.getAdvertisingIdInfo(activity).getId(), 0, ""));
                    } catch (IOException e) {
                        result.success(createJson("", -1, "IOException error: " + e.getMessage()));
                    } catch (GooglePlayServicesNotAvailableException e) {
                        result.success(createJson("", -1, "GooglePlayServicesNotAvailableException error: " + e.getMessage()));
                    } catch (GooglePlayServicesRepairableException e) {
                        result.success(createJson("", -1, "GooglePlayServicesRepairableException error: " + e.getMessage()));
                    } catch (Throwable t) {
                        result.success(createJson("", -1, "Throwable error: " + t.getMessage()));
                    }
                }).start();
            } catch (Exception e) {
                result.success(createJson("", -1, "Exception error: " + e.getMessage()));
            }

        } else {
            result.notImplemented();
        }
    }

    private String createJson(String gid, int code, String msg) {
        return "{\"gid\":\"" + gid + "\",\"code\":" + code + ",\"msg\":\"" + msg + "\"}";
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
    }
}
