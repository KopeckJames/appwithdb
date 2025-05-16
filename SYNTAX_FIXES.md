# Syntax Fixes for AddMealView.swift

I've fixed the syntax errors in the AddMealView.swift file. Here's a summary of the changes:

## 1. Fixed Pattern Matching Syntax

The original code was using pattern matching with `case` expressions outside of a switch statement, which is not allowed in this context:

```swift
// Original code with syntax error
if !(selectedImage != nil && !isAnalyzingImage && case .completed = analysisState) {
    // ...
}
```

Changed to a simpler boolean expression:

```swift
// Fixed code
if !(selectedImage != nil && !isAnalyzingImage && analysisState != .initial) {
    // ...
}
```

## 2. Fixed Enum Case Pattern Matching

The original code was using pattern matching with `case` to extract a value from an enum:

```swift
// Original code with syntax error
if selectedImage != nil && !isAnalyzingImage && case .completed(let analysis) = analysisState {
    // ...
}
```

Changed to use optional binding with the mealAnalysis property:

```swift
// Fixed code
if let analysis = mealAnalysis, selectedImage != nil && !isAnalyzingImage {
    // ...
}
```

## Why These Changes Work

1. The first change simplifies the condition by using a direct comparison instead of pattern matching.

2. The second change uses optional binding with the `mealAnalysis` property, which is already set when the analysis is completed. This avoids the need for pattern matching on the enum.

These changes maintain the same functionality while fixing the syntax errors. The app will still:
- Hide the Notes section when analysis results are shown
- Show the Analysis Results section when an analysis has been completed
- Display all the same information as before
