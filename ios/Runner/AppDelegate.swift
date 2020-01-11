import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    }

    if(!UserDefaults.standard.bool(forKey: "Notification")) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        UserDefaults.standard.set(true, forKey: "Notification")
    }

    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
