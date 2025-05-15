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

// Simple Profile View as a placeholder
struct ProfileView: View {
    @State private var isLoggedOut = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                Text("User: \(AuthManager.shared.currentUsername)")
                    .font(.headline)
                    .padding(.top, 10)
                
                Spacer()
                
                Button(action: {
                    print("Logout button tapped")
                    AuthManager.shared.logoutUser()
                    isLoggedOut = true
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .navigationBarTitle("Profile", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
