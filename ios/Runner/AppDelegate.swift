import Flutter
import UIKit
import FirebaseCore
import FirebaseCrashlytics

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    // iOS: APNs 등록 — 토큰이 늦으면 FCM getToken()이 오래 대기하는 원인이 됨
    // (참고: https://joominl.tistory.com/36 )
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let flavorChannel = FlutterMethodChannel(
      name: "flavor",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    flavorChannel.setMethodCallHandler { _, result in
      let flavor = Bundle.main.infoDictionary?["App-Flavor"]
      result(flavor)
    }
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
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
}
