import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let audioChannel = FlutterMethodChannel(name: "com.andy.ezlearning/audio",
                                          binaryMessenger: controller.binaryMessenger)

    audioChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if call.method == "configureAudioSession" {
        self.configureAudioSession(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureAudioSession(result: @escaping FlutterResult) {
    do {
      let audioSession = AVAudioSession.sharedInstance()

      // Configure audio session for webview media playback with correct options
      try audioSession.setCategory(.playback,
                                 mode: .default,
                                 options: [.mixWithOthers, .allowBluetooth])

      try audioSession.setActive(true, options: [])

      print("🔊 iOS Audio Session configured successfully for physical device")
      result("Audio session configured")

    } catch {
      print("🚨 Failed to configure iOS audio session: \(error)")

      // Try a simpler configuration if the first one fails
      do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.ambient)
        try audioSession.setActive(true)
        print("🔊 iOS Audio Session configured with ambient category")
        result("Audio session configured with ambient category")
      } catch {
        print("🚨 Failed to configure iOS audio session with ambient category: \(error)")
        result(FlutterError(code: "AUDIO_SESSION_ERROR",
                           message: "Failed to configure audio session",
                           details: error.localizedDescription))
      }
    }
  }
}
