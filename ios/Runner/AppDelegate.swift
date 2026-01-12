import Flutter
import UIKit
import FirebaseCore
import FirebaseCrashlytics

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase 초기화 (Flutter에서도 초기화되지만, 여기서도 명시적으로 초기화)
    FirebaseApp.configure()
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    GeneratedPluginRegistrant.register(with: self)

    let controller = window.rootViewController as! FlutterViewController

    let flavorChannel = FlutterMethodChannel(
        name: "flavor",
        binaryMessenger: controller.binaryMessenger)

    flavorChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        // Note: this method is invoked on the UI thread
        let flavor = Bundle.main.infoDictionary?["App-Flavor"]
        result(flavor)
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // URL Scheme 처리 (카카오톡 로그인 등)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Flutter의 app_links 플러그인이 처리하도록 먼저 시도
    if super.application(app, open: url, options: options) {
      return true
    }
    
    // 직접 처리하지 않고 app_links가 처리하도록 함
    // app_links는 내부적으로 이 메서드를 호출하므로 여기서는 super 호출만으로 충분
    return false
  }
  
  // Universal Links 처리
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Flutter의 app_links 플러그인이 처리하도록 먼저 시도
    if super.application(application, continue: userActivity, restorationHandler: restorationHandler) {
      return true
    }
    
    // Universal Link인 경우 처리
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      // app_links가 처리하도록 함
      return false
    }
    
    return false
  }
  
  // SceneDelegate를 사용하지 않는 경우를 위한 처리
  override func application(
    _ application: UIApplication,
    handleOpen url: URL
  ) -> Bool {
    return super.application(application, handleOpen: url)
  }
}
