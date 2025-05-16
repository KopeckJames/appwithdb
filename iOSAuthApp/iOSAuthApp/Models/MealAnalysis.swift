import Foundation
import UIKit

/// Model representing the analysis results of a meal image
public struct MealAnalysis {
    public let ingredients: [String]
    public let calories: Double
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let glycemicIndex: String
    public let diabeticFriendly: Bool
    public let healthRecommendations: String

    public init(
        ingredients: [String],
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        glycemicIndex: String,
        diabeticFriendly: Bool,
        healthRecommendations: String
    ) {
        self.ingredients = ingredients
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.glycemicIndex = glycemicIndex
        self.diabeticFriendly = diabeticFriendly
        self.healthRecommendations = healthRecommendations
    }
}
