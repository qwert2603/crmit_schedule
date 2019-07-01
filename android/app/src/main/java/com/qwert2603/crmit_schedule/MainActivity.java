package com.qwert2603.crmit_schedule;

import android.os.Bundle;
import android.util.Log;

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
                                result.success(0);
                                return;
                            }
                            if (call.method.contentEquals("getAccessToken")) {
                                result.success("bfe36786-ef73-4897-adc2-9304205a2d98");
                                return;
                            }
                            if (call.method.contentEquals("on401")) {
                                result.success(null);
                                return;
                            }
                            if (call.method.contentEquals("getCacheDir")) {
                                result.success(getCacheDir().getPath());
                                return;
                            }
                            if (call.method.contentEquals("navigateToGroup")) {
                                int groupId = call.argument("groupId");
                                String groupName = call.argument("groupName");
                                Log.d("AASSDD", "MainActivity navigateToGroup " + groupId + " " + groupName);
                                result.success(null);
                                return;
                            }
                            if (call.method.contentEquals("onNavigationIconClicked")) {
                                Log.d("AASSDD", "MainActivity onNavigationIconClicked");
                                MainActivity.this.finish();
                                result.success(null);
                                return;
                            }
                            result.notImplemented();
                        }
                );
    }
}
