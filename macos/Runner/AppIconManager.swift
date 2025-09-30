import Cocoa
import FlutterMacOS

// Helper class to manage the app icon based on theme
@objc class AppIconManager: NSObject {
    @objc static func updateAppIcon(isDark: Bool) {
        // macOS doesn't support changing app icon at runtime directly
        // We'd need to implement an app icon switcher service
        DispatchQueue.main.async {
            print("App icon theme change requested: \(isDark ? "dark" : "light")")
        }
    }
}
