import UIKit

// This is a minimal AppDelegate that doesn't do anything
// We're using CoreDataStack instead for Core Data operations
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("AppDelegate: application did finish launching")
        return true
    }
}
