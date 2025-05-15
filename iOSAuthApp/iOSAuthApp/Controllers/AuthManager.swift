import Foundation
import CoreData
import UIKit
import SwiftUI

class AuthManager {
    static let shared = AuthManager()

    private init() {
        print("AuthManager initialized")
    }

    // Current logged in user
    private(set) var currentUser: NSManagedObject?

    // Get username of current user
    var currentUsername: String {
        return currentUser?.value(forKeyPath: "username") as? String ?? "User"
    }

    // Register a new user
    func registerUser(username: String, email: String, password: String) -> Bool {
        print("Attempting to register user: \(username), \(email)")
        return CoreDataStack.shared.createUser(username: username, email: email, password: password)
    }

    // Login user
    func loginUser(email: String, password: String) -> Bool {
        print("Attempting to login user: \(email)")
        guard let user = CoreDataStack.shared.authenticateUser(email: email, password: password) else {
            print("Authentication failed for: \(email)")
            return false
        }

        print("Authentication successful for: \(email)")
        currentUser = user
        return true
    }

    // Logout user
    func logoutUser() {
        print("Logging out user")
        currentUser = nil
    }

    // Check if user is logged in
    var isUserLoggedIn: Bool {
        return currentUser != nil
    }

    // Create a test user for debugging
    func createTestUser() {
        CoreDataStack.shared.createTestUser()
    }
}
