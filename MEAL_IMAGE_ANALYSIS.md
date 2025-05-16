# Meal Image Analysis Feature

This document provides an overview of the meal image analysis feature that has been implemented in the app.

## Overview

The meal image analysis feature allows users to:

1. Take a photo of their meal or select one from their photo library
2. Submit the image to ChatGPT for analysis
3. Receive detailed nutritional and diabetic information about the meal
4. Store all this information in the database along with the image

## Implementation Details

### Components Added

1. **OpenAIService**: Handles communication with the ChatGPT API for image analysis
2. **Core Data Model Extensions**: Added new attributes to the Meal entity to store analysis results
3. **MealManager Extensions**: Added methods to handle image analysis and update meals with analysis results
4. **UI Updates**: Enhanced AddMealView to include image analysis functionality and display results

### Data Flow

1. User takes a photo or selects one from their photo library
2. User taps "Analyze Photo" button
3. Image is sent to ChatGPT via the OpenAIService
4. ChatGPT analyzes the image and returns nutritional and diabetic information
5. The app displays the analysis results to the user
6. When the user saves the meal, all the analysis data is stored in the database

## How to Use

### Adding a Meal with Image Analysis

1. Navigate to the "Add Meal" screen
2. Take a photo of your meal or select one from your photo library
3. Tap the "Analyze Photo" button
4. Wait for the analysis to complete (a progress indicator will be shown)
5. Review the analysis results, which include:
   - Ingredients detected
   - Estimated calories
   - Macronutrients (protein, carbs, fat)
   - Glycemic index
   - Whether the meal is diabetic-friendly
   - Health recommendations
6. Fill in any additional details about the meal
7. Tap "Save" to store the meal with all the analysis data

### Viewing Analysis Results

After saving a meal with analysis data, you can view the analysis results by:

1. Going to the "Meals" tab
2. Selecting the meal from the list
3. The analysis results will be displayed in the meal details screen

## Technical Notes

### API Configuration

Before using the meal image analysis feature, you need to configure your OpenAI API key:

1. Open the `OpenAIService.swift` file
2. Replace `"YOUR_OPENAI_API_KEY"` with your actual OpenAI API key

### Core Data Migration

The app includes a Core Data migration system that automatically adds the necessary attributes to the Meal entity:

- `ingredientsData`: Binary data to store the list of ingredients
- `glycemicIndex`: String to store the glycemic index (low, medium, high)
- `diabeticFriendly`: Boolean to indicate if the meal is suitable for diabetics
- `healthRecommendations`: String to store health recommendations

### OpenAI API Usage

The app uses OpenAI's GPT-4 Vision API to analyze meal images. The API is called with a specific prompt that asks for:

1. List of ingredients
2. Estimated calories
3. Macronutrients (protein, carbs, fat)
4. Glycemic index estimation
5. Whether the meal is suitable for diabetics
6. Health recommendations

The response is formatted as JSON for easy parsing.

## Limitations

1. The accuracy of the analysis depends on the quality of the image and the capabilities of the ChatGPT model
2. The app requires an internet connection to perform the analysis
3. Each image analysis counts as an API call to OpenAI, which may have cost implications

## Future Enhancements

Potential future enhancements for the meal image analysis feature:

1. Offline analysis capabilities
2. Ability to edit analysis results
3. Historical tracking of nutritional intake based on analyzed meals
4. Meal recommendations based on dietary preferences and health goals
