import Flutter
import UIKit

/// iOS 13+ UIScene 수명 주기 (iOS 18에서 미도입 시 흰 화면·경고 원인이 될 수 있음)
class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    // kakao_flutter_sdk는 AppDelegate.application(_:open:options:)로 URL을 처리하는데
    // SceneDelegate 환경(iOS 13+)에서는 해당 메서드가 호출되지 않으므로 수동으로 전달
    if let url = URLContexts.first?.url, url.scheme?.hasPrefix("kakao") == true {
      UIApplication.shared.delegate?.application?(
        UIApplication.shared,
        open: url,
        options: [:]
      )
    }
  }
}
