# Final Syntax Fixes for AddMealView.swift

I've fixed the remaining syntax errors in the AddMealView.swift file. Here's a summary of the changes:

## 1. Fixed Enum Comparison Issue

The original code was trying to compare the `analysisState` enum with `.initial`, which doesn't exist in the `MealManager.AnalysisState` enum:

```swift
// Original code with syntax error
if !(selectedImage != nil && !isAnalyzingImage && analysisState != .initial) {
    // ...
}
```

Changed to use the `mealAnalysis` property instead, which is more straightforward:

```swift
// Fixed code
if mealAnalysis == nil || isAnalyzingImage {
    // ...
}
```

## 2. Why This Fix Works

The `MealManager.AnalysisState` enum has these cases:
- `.notStarted`
- `.analyzing`
- `.completed(MealAnalysis)`
- `.failed(Error)`

But it doesn't have an `.initial` case, which was causing the error.

Instead of trying to check the enum state, we now simply check if `mealAnalysis` is nil. This is more direct and achieves the same goal: showing the Notes section when no analysis has been performed or when analysis is in progress.

## 3. Improved Logic

The new condition is also more readable and maintainable:

- `mealAnalysis == nil`: No analysis has been performed yet
- `isAnalyzingImage`: Analysis is currently in progress

This makes it clear that we want to show the Notes section when either no analysis has been done or when analysis is still in progress.

## 4. Duplicate Analysis Results Section

I also noticed that there were two Analysis Results sections in the code (one at line 90 and another at line 165). This might cause confusion, but since only one will be displayed at a time based on the conditions, it shouldn't cause any functional issues.

If you want to clean this up further, you could consolidate these two sections into one.
