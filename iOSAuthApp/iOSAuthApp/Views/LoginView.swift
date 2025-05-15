import SwiftUI
import CoreData

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isAuthenticated = false

    // Add environment object for managed object context
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            // Background color
            Color.white.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // App title/logo
                    Text("Auth App")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.top, 60)

                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.bottom, 30)

                    // Debug text - remove in production
                    Text("Debug: UI is rendering")
                        .font(.caption)
                        .foregroundColor(.gray)

                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Button(action: {
                        // Print debug info
                        print("Login button tapped")
                        print("Email: \(email), Password: \(password)")

                        if !email.isEmpty && !password.isEmpty {
                            if AuthManager.shared.loginUser(email: email, password: password) {
                                print("Login successful")
                                // Post notification that user logged in
                                NotificationCenter.default.post(name: Notification.Name("UserLoggedIn"), object: nil)
                                // No longer need to set isAuthenticated since we're using the notification system
                            } else {
                                print("Login failed")
                                alertMessage = "Invalid email or password"
                                showingAlert = true
                            }
                        } else {
                            alertMessage = "Please enter email and password"
                            showingAlert = true
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.top, 10)

                    Button(action: {
                        print("Register button tapped")
                        // We'll use a simple navigation approach instead of NavigationLink
                        // Get the managed object context from the environment
                        let registerView = RegisterView()
                            .environment(\.managedObjectContext, viewContext)

                        // Create a hosting controller for the SwiftUI view
                        let hostingController = UIHostingController(rootView: registerView)

                        // Present the hosting controller
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(hostingController, animated: true, completion: nil)
                        }
                    }) {
                        Text("Don't have an account? Register")
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                    }

                    // Add a test user button for debugging
                    Button(action: {
                        print("Creating test user")
                        let _ = AuthManager.shared.registerUser(username: "test", email: "test@example.com", password: "password")
                        email = "test@example.com"
                        password = "password"
                    }) {
                        Text("Create Test User")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    }

                    Spacer(minLength: 50)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isAuthenticated) {
            TabView {
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

                // Meal Log Tab
                MealLogView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Label("Meals", systemImage: "fork.knife")
                    }
                    .tag(2)

                // Profile Tab
                ProfileView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .accentColor(.blue)
        }
        .onAppear {
            print("LoginView appeared")
        }
    }
}
