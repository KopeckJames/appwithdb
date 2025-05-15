import SwiftUI
import CoreData

@main
struct AuthApp: App {
    // State to track if the app has been initialized
    @State private var isInitialized = false

    // State to track if user is logged in
    @State private var isLoggedIn = false

    // Initialize the Core Data stack
    private let coreDataStack = CoreDataStack.shared

    init() {
        // Set up any global configurations
        print("AuthApp initialized")

        // Print debug info about the environment
        print("SwiftUI version: \(ProcessInfo.processInfo.operatingSystemVersion)")
        print("Device: \(UIDevice.current.model)")
        print("iOS version: \(UIDevice.current.systemVersion)")

        // Check if user is already logged in
        isLoggedIn = AuthManager.shared.isUserLoggedIn
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoggedIn {
                    // Show the tab view if user is logged in
                    TabView {
                        // Home Tab
                        HomeView()
                            .environment(\.managedObjectContext, coreDataStack.viewContext)
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                            .tag(0)

                        // Health Tab
                        HealthView()
                            .environment(\.managedObjectContext, coreDataStack.viewContext)
                            .tabItem {
                                Label("Health", systemImage: "heart.fill")
                            }
                            .tag(1)

                        // Profile Tab
                        ProfileView()
                            .environment(\.managedObjectContext, coreDataStack.viewContext)
                            .tabItem {
                                Label("Profile", systemImage: "person.fill")
                            }
                            .tag(2)
                    }
                    .accentColor(.blue)
                    .onAppear {
                        print("TabView appeared")
                    }
                } else {
                    // Show the login view if user is not logged in
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
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserLoggedIn"))) { _ in
                            isLoggedIn = true
                        }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserLoggedOut"))) { _ in
                isLoggedIn = false
            }
        }
    }
}
