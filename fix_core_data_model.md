# Fix Core Data Model for Meal Analysis

The compilation errors are occurring because we're trying to use attributes in the Meal entity that don't exist in the Core Data model. Since we can't directly modify the .xcdatamodeld file through code, we need to update it manually in Xcode.

## Steps to Fix the Core Data Model

1. Open your Xcode project
2. Locate the `AuthModel.xcdatamodeld` file in the Project Navigator (under Models folder)
3. Click on it to open the Core Data model editor
4. Select the "Meal" entity in the editor
5. Add the following attributes to the Meal entity:

   | Attribute Name | Type | Description |
   |----------------|------|-------------|
   | ingredientsData | Binary Data | Stores the serialized list of ingredients |
   | glycemicIndex | String | Stores the glycemic index (low, medium, high) |
   | diabeticFriendly | Boolean | Indicates if the meal is suitable for diabetics |
   | healthRecommendations | String | Stores health recommendations |

6. Save the changes (Command+S)

## Alternative Approach: Modify MealExtensions.swift

If you can't modify the Core Data model directly, we can modify the MealExtensions.swift file to work with the existing model:

1. Open `MealExtensions.swift`
2. Replace the current implementation with the one that works with the existing model
3. This will allow you to use the meal image analysis feature without modifying the Core Data model

## Detailed Implementation

Here's a modified version of MealExtensions.swift that works with the existing Core Data model:

```swift
import Foundation
import CoreData
import UIKit

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
```

This implementation stores the analysis data as JSON in the existing `notes` field, which avoids the need to modify the Core Data model.
