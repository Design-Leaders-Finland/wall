import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    
    // Register method channel for icon updates
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    let iconChannel = FlutterMethodChannel(
        name: "fi.designleaders.wall/app_icon",
        binaryMessenger: controller.engine.binaryMessenger)
    
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
    let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    AppIconManager.updateAppIcon(isDark: isDark)
  }
}
