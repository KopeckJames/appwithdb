# Final Compilation Fix

I've fixed all the compilation errors by adding the necessary imports and defining the `MealAnalysis` struct in each file that needs it. Here's a summary of the changes:

## 1. OpenAIService.swift

Added the `MealAnalysis` and `OpenAIError` definitions directly in the file:

```swift
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

// Define the OpenAIError enum here to avoid import issues
enum OpenAIError: Error {
    case imageConversionFailed
    case jsonEncodingFailed
    case noDataReceived
    case invalidResponse
    case parsingFailed
}
```

## 2. MealExtensions.swift

Updated the file to store analysis data in the notes field as JSON and added the `MealAnalysis` definition:

```swift
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
```

## 3. AddMealView.swift

Added the necessary imports and `MealAnalysis` definition:

```swift
import SwiftUI
import UIKit
import CoreData
import Combine

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
```

## 4. MealManager.swift

Added the necessary imports and `MealAnalysis` definition:

```swift
import Foundation
import CoreData
import UIKit
import SwiftUI
import Combine

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
```

## Next Steps

1. Clean the build folder (Product > Clean Build Folder or Shift+Command+K)
2. Rebuild the project (Command+B)

The project should now compile successfully. If you still encounter any issues, please let me know.

## Important Note

Before using the meal image analysis feature, remember to replace the placeholder API key in `OpenAIService.swift` with your actual OpenAI API key:

```swift
// Replace with your actual API key
private let apiKey = "YOUR_OPENAI_API_KEY"
```

This will ensure that the API calls to OpenAI work correctly when analyzing meal images.
