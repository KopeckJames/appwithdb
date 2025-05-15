import Foundation
import CoreData

// Singleton class to manage Core Data operations
class CoreDataStack {
    static let shared = CoreDataStack()

    // The Core Data persistent container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AuthModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error loading Core Data: \(error), \(error.userInfo)")
            }

            // Configure the Core Data stack
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
        return container
    }()

    // The main view context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // Private initializer for singleton
    private init() {
        print("CoreDataStack initialized")

        // Initialize the Core Data stack immediately
        _ = persistentContainer
        print("Core Data stack loaded successfully")

        // Create a test user for debugging
        createTestUser()
    }

    // Save the context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    // Create a test user for debugging
    func createTestUser() {
        let context = viewContext

        // Check if we already have users
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                print("Creating test user for debugging")

                // Create a test user
                let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
                let user = NSManagedObject(entity: entity, insertInto: context)

                user.setValue(UUID(), forKeyPath: "id")
                user.setValue("test", forKeyPath: "username")
                user.setValue("test@example.com", forKeyPath: "email")
                user.setValue("password", forKeyPath: "password")

                try context.save()
                print("Test user created successfully")
            } else {
                print("Users already exist in database: \(count)")
            }
        } catch {
            print("Error checking/creating test user: \(error)")
        }
    }

    // Find a user by email
    func findUser(byEmail email: String) -> NSManagedObject? {
        let context = viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }

    // Create a new user
    func createUser(username: String, email: String, password: String) -> Bool {
        let context = viewContext

        // Check if user already exists
        if findUser(byEmail: email) != nil {
            return false
        }

        // Create new user
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        let user = NSManagedObject(entity: entity, insertInto: context)

        user.setValue(UUID(), forKeyPath: "id")
        user.setValue(username, forKeyPath: "username")
        user.setValue(email, forKeyPath: "email")
        user.setValue(password, forKeyPath: "password")

        // Save context
        do {
            try context.save()
            return true
        } catch {
            print("Error saving user: \(error)")
            return false
        }
    }

    // Authenticate a user
    func authenticateUser(email: String, password: String) -> NSManagedObject? {
        guard let user = findUser(byEmail: email) else {
            return nil
        }

        if let storedPassword = user.value(forKeyPath: "password") as? String,
           storedPassword == password {
            return user
        }

        return nil
    }
}
