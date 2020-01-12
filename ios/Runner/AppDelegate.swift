import UIKit
import Flutter
import workmanager

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
        
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            // The following code will be called upon WorkmanagerPlugin's registration.
            // Note : all of the app's plugins may not be required in this context ;
            // instead of using GeneratedPluginRegistrant.register(with: registry),
            // you may want to register only specific plugins.
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        if(!UserDefaults.standard.bool(forKey: "Notification")) {
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()
            UserDefaults.standard.set(true, forKey: "Notification")
        }

        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*360))

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
