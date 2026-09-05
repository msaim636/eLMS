import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()

        // Register plugins
        GeneratedPluginRegistrant.register(with: self)

        // Screen protection is now handled by the screen_protector Flutter package
        // See lib/main.dart for implementation using ScreenProtector.protectDataLeakageOn()
        // Native screenshot/screen recording detection code has been removed

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
