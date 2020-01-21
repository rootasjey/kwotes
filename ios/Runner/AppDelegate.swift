import UIKit
import Firebase
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    /// Registers all pubspec-referenced Flutter plugins in the given registry.
    static func registerPlugins(with registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        //FirebaseApp.configure()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
