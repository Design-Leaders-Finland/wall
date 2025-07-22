import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register method channel for icon updates
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("Warning: Could not get FlutterViewController for icon channel setup")
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    let iconChannel = FlutterMethodChannel(
        name: "fi.designleaders.wall/app_icon",
        binaryMessenger: controller.binaryMessenger)
    
    iconChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "updateAppIcon" {
        if let args = call.arguments as? [String: Any],
           let isDark = args["isDark"] as? Bool {
          AppIconManager.updateAppIcon(isDark: isDark)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are missing or invalid", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Set initial icon based on current theme
    let isDark = window?.traitCollection.userInterfaceStyle == .dark
    AppIconManager.updateAppIcon(isDark: isDark)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
