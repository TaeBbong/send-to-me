import Flutter
import UIKit

/// On the modern UIScene-based template, URL opens are delivered to the scene
/// delegate instead of `AppDelegate.application(_:open:options:)`. The
/// share_handler plugin still listens on the legacy app-delegate API, so we
/// bridge both the cold-start (`willConnectTo`) and warm (`openURLContexts`)
/// URL events back to the app delegate. Without this, content shared into the
/// app never reaches Dart on iOS.
class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    forwardToAppDelegate(connectionOptions.urlContexts)
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    forwardToAppDelegate(URLContexts)
  }

  private func forwardToAppDelegate(_ contexts: Set<UIOpenURLContext>) {
    guard let url = contexts.first?.url,
          let appDelegate = UIApplication.shared.delegate else { return }
    _ = appDelegate.application?(
      UIApplication.shared,
      open: url,
      options: [:]
    )
  }
}
