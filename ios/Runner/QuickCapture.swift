import AppIntents
import Flutter
import Foundation

/// A tiny FIFO queue of quick-capture texts, stored in the App Group container so
/// it survives the app being closed and is shared between the app, the Share
/// Extension, and App Intents.
///
/// `CaptureMemoIntent` appends here (it can run in the background, with the app
/// closed). The Flutter app drains it on launch/resume via the
/// `app/quick_capture` channel and turns each entry into a memo. Native code
/// never touches the Drift database — it only buffers raw text.
enum QuickCaptureStore {
  static let appGroupId = "group.com.taebbong.sendtome"
  static let key = "quick_capture_pending"

  private static var defaults: UserDefaults? {
    UserDefaults(suiteName: appGroupId)
  }

  static func append(_ text: String) {
    guard let defaults = defaults else { return }
    var list = defaults.stringArray(forKey: key) ?? []
    list.append(text)
    defaults.set(list, forKey: key)
  }

  /// Returns every queued capture (oldest first) and clears the queue.
  static func drain() -> [String] {
    guard let defaults = defaults else { return [] }
    let list = defaults.stringArray(forKey: key) ?? []
    defaults.removeObject(forKey: key)
    return list
  }
}

/// App Intent that captures a memo without opening the app. Assign it to Back
/// Tap, the Action Button, a Control, or run it from Shortcuts/Spotlight; iOS
/// prompts for the text via the system dialog ("Ask Each Time") and the save
/// runs in the background (`openAppWhenRun = false`). The memo is imported and
/// classified the next time the app runs.
@available(iOS 16.0, *)
struct CaptureMemoIntent: AppIntent {
  static var title: LocalizedStringResource = "빠른 메모"
  static var description = IntentDescription("앱을 열지 않고 메모를 빠르게 저장해요.")
  static var openAppWhenRun: Bool = false

  @Parameter(title: "메모", requestValueDialog: "무엇을 메모할까요?")
  var text: String

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty {
      QuickCaptureStore.append(trimmed)
    }
    return .result(dialog: "메모를 저장했어요")
  }
}

/// Makes `CaptureMemoIntent` discoverable in the Shortcuts app and Spotlight
/// without the user building a shortcut by hand, and exposes Siri phrases.
@available(iOS 16.0, *)
struct QuickCaptureShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: CaptureMemoIntent(),
      phrases: [
        "\(.applicationName)에 메모",
        "\(.applicationName) 빠른 메모",
      ],
      shortTitle: "빠른 메모",
      systemImageName: "square.and.pencil"
    )
  }
}

/// Bridges the App Group capture queue to Flutter. The Dart side calls
/// `drainPending` on launch/resume to pull-and-clear anything captured while it
/// was closed (see `QuickCaptureService`).
class QuickCapturePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app/quick_capture",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(QuickCapturePlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "drainPending":
      result(QuickCaptureStore.drain())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
