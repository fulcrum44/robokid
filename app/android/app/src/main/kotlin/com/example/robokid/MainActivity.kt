package com.example.robokid

import android.os.Bundle
import android.telephony.TelephonyManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "robokid/connectivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isMobileDataEnabled") {
                    val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                    result.success(tm.isDataEnabled)
                } else {
                    result.notImplemented()
                }
            }
    }
}