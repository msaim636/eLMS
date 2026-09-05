package com.wrteam.elms
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Screen protection is now handled by the screen_protector Flutter package
        // See lib/main.dart for implementation using ScreenProtector.protectDataLeakageOn()
        // Native implementation below is no longer needed:
        // window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
}
