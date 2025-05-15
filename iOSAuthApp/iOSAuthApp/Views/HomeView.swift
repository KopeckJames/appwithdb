import SwiftUI
import CoreData

struct HomeView: View {
    @State private var isLoggedOut = false
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            // Background color
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Debug text - remove in production
                Text("Debug: Home UI is rendering")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 20)

                Text("Welcome, \(AuthManager.shared.currentUsername)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                Text("You are now logged in")
                    .font(.headline)
                    .padding(.bottom, 20)

                // Add some placeholder content
                VStack(alignment: .leading, spacing: 15) {
                    Text("Account Information")
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
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
                .environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            print("Home view appeared with user: \(AuthManager.shared.currentUsername)")
        }
    }
}
