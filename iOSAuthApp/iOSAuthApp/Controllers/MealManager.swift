
import Foundation
import CoreData
import UIKit
import SwiftUI
import Combine

class MealManager {
    static let shared = MealManager()

    // Publishers for async operations
    private var cancellables = Set<AnyCancellable>()

    // Analysis state
    enum AnalysisState {
        case notStarted
        case analyzing
        case completed(MealAnalysis)
        case failed(Error)
    }

    private init() {
        print("MealManager initialized")
    }

    // MARK: - Meal Operations

    // Create a new meal
    func createMeal(title: String, mealType: String, notes: String, photo: UIImage?, foodItems: [FoodItemData], context: NSManagedObjectContext) -> Bool {
        let meal = NSEntityDescription.insertNewObject(forEntityName: "Meal", into: context) as! Meal

        meal.id = UUID()
        meal.title = title
        meal.mealType = mealType
        meal.notes = notes
        meal.date = Date()
        meal.totalCalories = 0.0

        // Save photo if available
        if let photo = photo {
            if let imageData = photo.jpegData(compressionQuality: 0.7) {
                meal.photoData = imageData
            }
        }

        // Add food items
        var totalCalories: Double = 0.0

        for itemData in foodItems {
            let foodItem = NSEntityDescription.insertNewObject(forEntityName: "FoodItem", into: context) as! FoodItem
            foodItem.name = itemData.name
            foodItem.calories = itemData.calories
            foodItem.protein = itemData.protein
            foodItem.carbs = itemData.carbs
            foodItem.fat = itemData.fat
            foodItem.servingSize = itemData.servingSize
            foodItem.meal = meal

            totalCalories += itemData.calories
        }

        meal.totalCalories = totalCalories

        // Associate with current user
        if let currentUser = AuthManager.shared.currentUser as? User {
            meal.user = currentUser
        }

        do {
            try context.save()
            print("Meal saved successfully")
            return true
        } catch {
            print("Error saving meal: \(error)")
            return false
        }
    }

    // Update an existing meal
    func updateMeal(meal: Meal, title: String, mealType: String, notes: String, photo: UIImage?, foodItems: [FoodItemData], context: NSManagedObjectContext) -> Bool {
        meal.title = title
        meal.mealType = mealType
        meal.notes = notes

        // Update photo if a new one is provided
        if let photo = photo {
            if let imageData = photo.jpegData(compressionQuality: 0.7) {
                meal.photoData = imageData
            }
        }

        // Remove existing food items
        if let existingItems = meal.foodItems as? Set<FoodItem> {
            for item in existingItems {
                context.delete(item)
            }
        }

        // Add new food items
        var totalCalories: Double = 0.0

        for itemData in foodItems {
            let foodItem = NSEntityDescription.insertNewObject(forEntityName: "FoodItem", into: context) as! FoodItem
            foodItem.name = itemData.name
            foodItem.calories = itemData.calories
            foodItem.protein = itemData.protein
            foodItem.carbs = itemData.carbs
            foodItem.fat = itemData.fat
            foodItem.servingSize = itemData.servingSize
            foodItem.meal = meal

            totalCalories += itemData.calories
        }

        meal.totalCalories = totalCalories

        do {
            try context.save()
            print("Meal updated successfully")
            return true
        } catch {
            print("Error updating meal: \(error)")
            return false
        }
    }

    // Delete a meal
    func deleteMeal(meal: Meal, context: NSManagedObjectContext) -> Bool {
        context.delete(meal)

        do {
            try context.save()
            print("Meal deleted successfully")
            return true
        } catch {
            print("Error deleting meal: \(error)")
            return false
        }
    }

    // Get all meals for the current user
    func getMealsForCurrentUser(context: NSManagedObjectContext) -> [Meal] {
        guard let currentUser = AuthManager.shared.currentUser as? User else {
            return []
        }

        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", currentUser)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let meals = try context.fetch(fetchRequest)
            return meals
        } catch {
            print("Error fetching meals: \(error)")
            return []
        }
    }

    // Get meals for a specific date
    func getMealsForDate(date: Date, context: NSManagedObjectContext) -> [Meal] {
        guard let currentUser = AuthManager.shared.currentUser as? User else {
            return []
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date < %@",
                                            currentUser, startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            let meals = try context.fetch(fetchRequest)
            return meals
        } catch {
            print("Error fetching meals for date: \(error)")
            return []
        }
    }

    // MARK: - Meal Analysis

    /// Analyze a meal image using OpenAI's vision API
    /// - Parameters:
    ///   - meal: The meal to analyze
    ///   - context: The managed object context
    ///   - completion: Callback with success status and optional error
    func analyzeMealImage(meal: Meal, context: NSManagedObjectContext, completion: @escaping (Bool, Error?) -> Void) {
        guard let image = meal.image else {
            completion(false, NSError(domain: "com.meal.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No image available for analysis"]))
            return
        }

        // Call OpenAI service to analyze the image
        OpenAIService.shared.analyzeMealImage(image: image) { result in
            switch result {
            case .success(let analysis):
                // Update meal with analysis results
                meal.updateWithAnalysis(analysis, context: context)
                completion(true, nil)

            case .failure(let error):
                print("Error analyzing meal image: \(error)")
                completion(false, error)
            }
        }
    }

    /// Create a meal with image analysis
    /// - Parameters:
    ///   - title: The meal title
    ///   - mealType: The type of meal (breakfast, lunch, dinner, snack)
    ///   - notes: Additional notes about the meal
    ///   - photo: The meal photo
    ///   - context: The managed object context
    ///   - analyzeImage: Whether to analyze the image
    ///   - completion: Callback with the created meal and analysis state
    func createMealWithAnalysis(
        title: String,
        mealType: String,
        notes: String,
        photo: UIImage?,
        context: NSManagedObjectContext,
        analyzeImage: Bool = false,
        completion: @escaping (Meal?, AnalysisState) -> Void
    ) {
        // First create the meal
        let meal = NSEntityDescription.insertNewObject(forEntityName: "Meal", into: context) as! Meal

        meal.id = UUID()
        meal.title = title
        meal.mealType = mealType
        meal.notes = notes
        meal.date = Date()
        meal.totalCalories = 0.0

        // Save photo if available
        if let photo = photo {
            if let imageData = photo.jpegData(compressionQuality: 0.7) {
                meal.photoData = imageData
            }
        }

        // Associate with current user
        if let currentUser = AuthManager.shared.currentUser as? User {
            meal.user = currentUser
        }

        // Save the meal
        do {
            try context.save()
            print("Meal created successfully")

            // If analyze image is requested and we have a photo
            if analyzeImage, let photo = photo {
                completion(meal, .analyzing)

                // Analyze the image
                OpenAIService.shared.analyzeMealImage(image: photo) { result in
                    switch result {
                    case .success(let analysis):
                        // Update meal with analysis results
                        meal.updateWithAnalysis(analysis, context: context)
                        completion(meal, .completed(analysis))

                    case .failure(let error):
                        print("Error analyzing meal image: \(error)")
                        completion(meal, .failed(error))
                    }
                }
            } else {
                completion(meal, .notStarted)
            }
        } catch {
            print("Error saving meal: \(error)")
            completion(nil, .failed(error))
        }
    }
}

// Helper struct for food item data
struct FoodItemData {
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String

    init(name: String, calories: Double, protein: Double, carbs: Double, fat: Double, servingSize: String) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
    }
}
