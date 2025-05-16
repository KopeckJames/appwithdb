import SwiftUI
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Health Tab
            HealthView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                .tag(1)

            // Profile Tab (placeholder for future expansion)
            ProfileView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

// Note: The ProfileView is defined in its own file (ProfileView.swift)
// This is just a reference to that view
