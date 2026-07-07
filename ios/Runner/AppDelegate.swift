import Flutter
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import FirebaseCrashlytics
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

    FirebaseApp.configure()
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      let flavorChannel = FlutterMethodChannel(
        name: "flavor",
        binaryMessenger: controller.binaryMessenger
      )
      flavorChannel.setMethodCallHandler { _, result in
        let flavor = Bundle.main.infoDictionary?["App-Flavor"]
        result(flavor)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]) {
      return true
    }
    if super.application(app, open: url, options: options) {
      return true
    }
    return false
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if super.application(application, continue: userActivity, restorationHandler: restorationHandler) {
      return true
    }
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       userActivity.webpageURL != nil {
      return false
    }
    return false
  }

  override func application(
    _ application: UIApplication,
    handleOpen url: URL
  ) -> Bool {
    return super.application(application, handleOpen: url)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("✅ APNs 토큰 등록됨")
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ APNs 등록 실패: \(error)")
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    print("📨 didReceiveRemoteNotification 호출됨")
    if Auth.auth().canHandleNotification(userInfo) {
      print("✅ FirebaseAuth가 notification 처리함")
      completionHandler(.noData)
      return
    }
    Messaging.messaging().appDidReceiveMessage(userInfo)
    completionHandler(.newData)
  }
}
