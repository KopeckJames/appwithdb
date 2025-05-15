import SwiftUI
import CoreData

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isRegistered = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            // Background color
            Color.white.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    // Debug text - remove in production
                    Text("Debug: Register UI is rendering")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 20)

                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .disableAutocorrection(true)

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

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Button(action: {
                        // Print debug info
                        print("Register button tapped")
                        print("Username: \(username), Email: \(email)")

                        // Basic validation
                        if username.isEmpty || email.isEmpty || password.isEmpty {
                            alertMessage = "All fields are required"
                            showingAlert = true
                            return
                        }

                        if password != confirmPassword {
                            print("Passwords do not match")
                            alertMessage = "Passwords do not match"
                            showingAlert = true
                            return
                        }

                        if AuthManager.shared.registerUser(username: username, email: email, password: password) {
                            print("Registration successful")
                            isRegistered = true
                            alertMessage = "Registration successful! Please login."
                            showingAlert = true
                        } else {
                            print("Registration failed")
                            alertMessage = "Registration failed. Email may already be in use."
                            showingAlert = true
                        }
                    }) {
                        Text("Register")
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
                        print("Dismissing RegisterView")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Already have an account? Login")
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                    }

                    Spacer(minLength: 50)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(isRegistered ? "Success" : "Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isRegistered {
                        print("Dismissing after successful registration")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .onAppear {
            print("RegisterView appeared")
        }
    }
}
