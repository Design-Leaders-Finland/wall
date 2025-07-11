// Helper for switching between light/dark app icons
import UIKit

extension UIApplication {
    func setAlternateIconName(_ iconName: String?) {
        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print("Error setting alternate icon: \(error)")
                }
            }
        }
    }
}

@objc class AppIconManager: NSObject {
    @objc static func updateAppIcon(isDark: Bool) {
        // Set to dark icon when in dark mode, otherwise use the default icon
        UIApplication.shared.setAlternateIconName(isDark ? "AppIcon-Dark" : nil)
    }
}
