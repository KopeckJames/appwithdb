import SwiftUI
import CoreData

struct ProfileView: View {
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
                
                // User information card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Account Details")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Text("Username:")
                        Spacer()
                        Text(AuthManager.shared.currentUsername)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Status:")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // App settings card
                VStack(alignment: .leading, spacing: 15) {
                    Text("App Settings")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Toggle(isOn: .constant(true)) {
                        Text("Enable Notifications")
                    }
                    
                    Divider()
                    
                    Toggle(isOn: .constant(true)) {
                        Text("Dark Mode")
                    }
                    
                    Divider()
                    
                    Toggle(isOn: .constant(true)) {
                        Text("Sync Health Data")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    print("Logout button tapped")
                    AuthManager.shared.logoutUser()
                    // Post notification that user logged out
                    NotificationCenter.default.post(name: Notification.Name("UserLoggedOut"), object: nil)
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
            .navigationBarTitle("Profile", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
