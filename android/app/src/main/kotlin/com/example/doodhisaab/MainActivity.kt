package com.example.doodhisaab

import android.os.Bundle
import android.app.AlertDialog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val backGuardChannel = "doodhisaab/back_guard"
    private val guardedRoutes = setOf(
        "/lock",
        "/onboarding",
        "/home",
        "/customers",
        "/reports",
        "/settings",
    )

    private var currentRoute: String = "/lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, backGuardChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setCurrentRoute" -> {
                        currentRoute = call.arguments as? String ?: "/lock"
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (currentRoute in guardedRoutes) {
            showExitDialog()
            return
        }
        super.onBackPressed()
    }

    private fun showExitDialog() {
        AlertDialog.Builder(this)
            .setTitle("Exit app?")
            .setMessage("Yes will close DoodHisaab. Cancel will keep the app open.")
            .setPositiveButton("Yes") { dialog, _ ->
                dialog.dismiss()
                finish()
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }
}
