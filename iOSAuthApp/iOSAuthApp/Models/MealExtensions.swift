import Foundation
import CoreData
import UIKit

// Define the MealAnalysis struct here to avoid import issues
struct MealAnalysis {
    let ingredients: [String]
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let glycemicIndex: String
    let diabeticFriendly: Bool
    let healthRecommendations: String
}

// MARK: - Meal Extensions

extension Meal {
    // Store analysis data in the notes field as JSON
    private var analysisData: [String: Any]? {
        get {
            guard let notesText = notes, !notesText.isEmpty else { return nil }

            // Check if notes contain JSON data
            if notesText.hasPrefix("{") && notesText.hasSuffix("}") {
                if let data = notesText.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    return json
                }
            }
            return nil
        }
        set {
            if let newValue = newValue,
               let jsonData = try? JSONSerialization.data(withJSONObject: newValue),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                // Store the JSON in the notes field
                notes = jsonString
            }
        }
    }

    // Convenience method to get the analyzed ingredients
    var ingredientsArray: [String] {
        get {
            if let ingredients = analysisData?["ingredients"] as? [String] {
                return ingredients
            }
            return []
        }
        set {
            var data = analysisData ?? [:]
            data["ingredients"] = newValue
            analysisData = data
        }
    }

    // Convenience method to get the health recommendations
    var healthRecommendationsText: String {
        get {
            analysisData?["healthRecommendations"] as? String ?? ""
        }
        set {
            var data = analysisData ?? [:]
            data["healthRecommendations"] = newValue
            analysisData = data
        }
    }

    // Convenience method to get the glycemic index
    var glycemicIndexValue: String {
        get {
            analysisData?["glycemicIndex"] as? String ?? "Unknown"
        }
        set {
            var data = analysisData ?? [:]
            data["glycemicIndex"] = newValue
            analysisData = data
        }
    }

    // Convenience method to check if meal is diabetic friendly
    var isDiabeticFriendly: Bool {
        get {
            analysisData?["diabeticFriendly"] as? Bool ?? false
        }
        set {
            var data = analysisData ?? [:]
            data["diabeticFriendly"] = newValue
            analysisData = data
        }
    }

    // Convenience method to get the image
    var image: UIImage? {
        get {
            if let photoData = photoData {
                return UIImage(data: photoData)
            }
            return nil
        }
        set {
            if let newValue = newValue, let data = newValue.jpegData(compressionQuality: 0.7) {
                photoData = data
            } else {
                photoData = nil
            }
        }
    }

    // Convenience method to get the formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        if let date = date {
            return formatter.string(from: date)
        }
        return "Unknown date"
    }

    // Convenience method to get the meal type icon
    var typeIcon: String {
        switch mealType?.lowercased() {
        case "breakfast":
            return "sunrise"
        case "lunch":
            return "sun.max"
        case "dinner":
            return "moon.stars"
        case "snack":
            return "cup.and.saucer"
        default:
            return "fork.knife"
        }
    }

    // Convenience method to update meal with analysis results
    func updateWithAnalysis(_ analysis: MealAnalysis, context: NSManagedObjectContext) {
        // Update meal with analysis data
        self.ingredientsArray = analysis.ingredients
        self.totalCalories = analysis.calories
        self.glycemicIndexValue = analysis.glycemicIndex
        self.isDiabeticFriendly = analysis.diabeticFriendly
        self.healthRecommendationsText = analysis.healthRecommendations

        // Create or update food items based on ingredients
        if let existingItems = self.foodItems as? Set<FoodItem> {
            for item in existingItems {
                context.delete(item)
            }
        }

        // Create a food item for the analyzed meal
        let foodItem = FoodItem(context: context)
        foodItem.name = "Analyzed Meal"
        foodItem.calories = analysis.calories
        foodItem.protein = analysis.protein
        foodItem.carbs = analysis.carbs
        foodItem.fat = analysis.fat
        foodItem.servingSize = "1 serving"
        foodItem.meal = self

        // Save context
        do {
            try context.save()
            print("Meal updated with analysis data")
        } catch {
            print("Error saving meal analysis: \(error)")
        }
    }
}

// MARK: - FoodItem Extensions

extension FoodItem {
    // Convenience method to get the macronutrient percentages
    var proteinPercentage: Double {
        let total = protein + carbs + fat
        return total > 0 ? (protein / total) * 100 : 0
    }

    var carbsPercentage: Double {
        let total = protein + carbs + fat
        return total > 0 ? (carbs / total) * 100 : 0
    }

    var fatPercentage: Double {
        let total = protein + carbs + fat
        return total > 0 ? (fat / total) * 100 : 0
    }

    // Convenience method to get the formatted calories
    var formattedCalories: String {
        return "\(Int(calories)) kcal"
    }

    // Convenience method to get the formatted macronutrients
    var formattedMacros: String {
        return "P: \(Int(protein))g • C: \(Int(carbs))g • F: \(Int(fat))g"
    }
}
