import SwiftUI
import CoreData

@main
struct AuthApp: App {
    // State to track if the app has been initialized
    @State private var isInitialized = false

    // Initialize the Core Data stack
    private let coreDataStack = CoreDataStack.shared

    init() {
        // Set up any global configurations
        print("AuthApp initialized")

        // Print debug info about the environment
        print("SwiftUI version: \(ProcessInfo.processInfo.operatingSystemVersion)")
        print("Device: \(UIDevice.current.model)")
        print("iOS version: \(UIDevice.current.systemVersion)")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Create the first view with the managed object context
                LoginView()
                    .environment(\.managedObjectContext, coreDataStack.viewContext)
                    .onAppear {
                        // Print some debug info when the app starts
                        print("App started with Core Data context: \(coreDataStack.viewContext)")

                        // Create a test user for debugging if needed
                        if !isInitialized {
                            AuthManager.shared.createTestUser()
                            isInitialized = true
                        }
                    }
            }
        }
    }
}
