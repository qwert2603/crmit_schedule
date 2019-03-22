package com.qwert2603.crmit_schedule;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        MethodChannel methodChannel = new MethodChannel(getFlutterView(), "app.channel.schedule");

        methodChannel
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.contentEquals("getAuthedTeacherIdOrZero")) {
                                result.success(1);
                                return;
                            }
                            if (call.method.contentEquals("getAccessToken")) {
                                result.success("ac28bd98-afc4-4310-90ee-017515a636ba");
                                return;
                            }
                            if (call.method.contentEquals("on401")) {
                                result.success("ok");
                                methodChannel.invokeMethod("clearCache", null);
                                return;
                            }
                            result.notImplemented();
                        }
                );
    }
}
