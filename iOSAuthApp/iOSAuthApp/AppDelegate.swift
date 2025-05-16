import UIKit
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("AppDelegate: application did finish launching")

        // Perform Core Data migrations
        CoreDataMigration.shared.performMigrations()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the Core Data context before the app terminates
        saveContext()
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = CoreDataStack.shared.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
