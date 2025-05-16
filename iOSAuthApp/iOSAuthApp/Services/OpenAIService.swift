import Foundation
import UIKit
import Combine

// Define the OpenAIError enum here to avoid import issues
enum OpenAIError: Error {
    case imageConversionFailed
    case jsonEncodingFailed
    case noDataReceived
    case invalidResponse
    case parsingFailed
}

class OpenAIService {
    static let shared = OpenAIService()

    // Replace with your actual API key
    private let apiKey = "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" // You need to replace this with a valid OpenAI API key
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    private init() {
        print("OpenAIService initialized")
    }

    // MARK: - Image Analysis

    /// Analyzes a meal image and extracts nutritional and diabetic information
    /// - Parameters:
    ///   - image: The meal image to analyze
    ///   - completion: Callback with the analysis result or error
    func analyzeMealImage(image: UIImage, completion: @escaping (Result<MealAnalysis, Error>) -> Void) {
        // Convert image to base64 string
        guard let imageData = image.jpegData(compressionQuality: 0.7),
              let base64String = convertImageToBase64(imageData: imageData) else {
            completion(.failure(OpenAIError.imageConversionFailed))
            return
        }

        // Create the request
        let prompt = "Analyze this food image and provide detailed nutritional information. Include: 1) List of ingredients you can identify, 2) Estimated calories, 3) Macronutrients (protein, carbs, fat) in grams, 4) Glycemic index estimation (low, medium, high), 5) Whether this meal is suitable for diabetics, and 6) Any health recommendations. Format the response as JSON with these keys: ingredients, calories, protein, carbs, fat, glycemicIndex, diabeticFriendly, healthRecommendations."

        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a nutritional analysis AI that specializes in analyzing food images and providing detailed nutritional information."],
            ["role": "user", "content": [
                ["type": "text", "text": prompt],
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64String)"]]
            ]]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 1000
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(OpenAIError.jsonEncodingFailed))
            return
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(OpenAIError.noDataReceived))
                return
            }

            do {
                // Print the raw response for debugging
                let responseString = String(data: data, encoding: .utf8)
                print("OpenAI API Response: \(responseString ?? "Unable to convert data to string")")

                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Check for error in the response
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("OpenAI API Error: \(message)")
                        completion(.failure(NSError(domain: "OpenAI", code: 1000, userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }

                    // Try to extract the content
                    if let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {

                        print("OpenAI Content: \(content)")

                        // Parse the JSON response from the content
                        if let analysis = self.parseAnalysisFromResponse(content) {
                            completion(.success(analysis))
                        } else {
                            print("Failed to parse analysis from response")
                            completion(.failure(OpenAIError.parsingFailed))
                        }
                    } else {
                        print("Invalid response format: \(json)")
                        completion(.failure(OpenAIError.invalidResponse))
                    }
                } else {
                    print("Failed to parse JSON response")
                    completion(.failure(OpenAIError.invalidResponse))
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // MARK: - Helper Methods

    private func convertImageToBase64(imageData: Data) -> String? {
        return imageData.base64EncodedString()
    }

    private func parseAnalysisFromResponse(_ response: String) -> MealAnalysis? {
        print("Attempting to parse response: \(response)")

        // Try different approaches to extract JSON

        // Approach 1: Extract JSON using regex
        let jsonPattern = "\\{[\\s\\S]*\\}"
        if let regex = try? NSRegularExpression(pattern: jsonPattern),
           let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
           let range = Range(match.range, in: response) {

            let jsonString = String(response[range])
            print("Extracted JSON string: \(jsonString)")

            if let analysis = parseJsonString(jsonString) {
                return analysis
            }
        }

        // Approach 2: Try to parse the entire response as JSON
        if let analysis = parseJsonString(response) {
            return analysis
        }

        // Approach 3: Try to find JSON by looking for opening brace
        if let startIndex = response.firstIndex(of: "{"),
           let endIndex = response.lastIndex(of: "}") {
            let jsonSubstring = response[startIndex...endIndex]
            let jsonString = String(jsonSubstring)
            print("Extracted JSON substring: \(jsonString)")

            if let analysis = parseJsonString(jsonString) {
                return analysis
            }
        }

        // If all approaches fail, create a default analysis with the response as a note
        print("All parsing approaches failed, creating default analysis")
        return MealAnalysis(
            ingredients: ["Unknown"],
            calories: 0.0,
            protein: 0.0,
            carbs: 0.0,
            fat: 0.0,
            glycemicIndex: "Unknown",
            diabeticFriendly: false,
            healthRecommendations: "Failed to parse response: \(response)"
        )
    }

    private func parseJsonString(_ jsonString: String) -> MealAnalysis? {
        do {
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("Failed to convert string to data")
                return nil
            }

            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            print("Parsed JSON: \(String(describing: json))")

            // Extract values from JSON
            let ingredients = extractIngredients(from: json)
            let calories = extractDouble(for: "calories", from: json) ?? 0.0
            let protein = extractDouble(for: "protein", from: json) ?? 0.0
            let carbs = extractDouble(for: "carbs", from: json) ?? 0.0
            let fat = extractDouble(for: "fat", from: json) ?? 0.0
            let glycemicIndex = extractString(for: "glycemicIndex", from: json) ?? "Unknown"
            let diabeticFriendly = extractBool(for: "diabeticFriendly", from: json) ?? false
            let healthRecommendations = extractString(for: "healthRecommendations", from: json) ?? ""

            return MealAnalysis(
                ingredients: ingredients,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                glycemicIndex: glycemicIndex,
                diabeticFriendly: diabeticFriendly,
                healthRecommendations: healthRecommendations
            )
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }

    private func extractIngredients(from json: [String: Any]?) -> [String] {
        guard let json = json else { return [] }

        // Try to extract as array of strings
        if let ingredients = json["ingredients"] as? [String] {
            return ingredients
        }

        // Try to extract as string and split by commas or newlines
        if let ingredientsString = json["ingredients"] as? String {
            let separators = CharacterSet(charactersIn: ",\n")
            return ingredientsString.components(separatedBy: separators)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return []
    }

    private func extractDouble(for key: String, from json: [String: Any]?) -> Double? {
        guard let json = json else { return nil }

        // Try to extract as Double
        if let value = json[key] as? Double {
            return value
        }

        // Try to extract as Int and convert
        if let value = json[key] as? Int {
            return Double(value)
        }

        // Try to extract as String and convert
        if let valueString = json[key] as? String,
           let value = Double(valueString.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return value
        }

        return nil
    }

    private func extractString(for key: String, from json: [String: Any]?) -> String? {
        guard let json = json else { return nil }

        // Try to extract as String
        if let value = json[key] as? String {
            return value
        }

        // Try to extract as any value and convert to string
        if let value = json[key] {
            return "\(value)"
        }

        return nil
    }

    private func extractBool(for key: String, from json: [String: Any]?) -> Bool? {
        guard let json = json else { return nil }

        // Try to extract as Bool
        if let value = json[key] as? Bool {
            return value
        }

        // Try to extract as String and convert
        if let valueString = json[key] as? String {
            let lowercased = valueString.lowercased()
            if lowercased == "true" || lowercased == "yes" {
                return true
            } else if lowercased == "false" || lowercased == "no" {
                return false
            }
        }

        // Try to extract as Int and convert
        if let value = json[key] as? Int {
            return value != 0
        }

        return nil
    }
}

// Note: MealAnalysis and OpenAIError are defined in MealAnalysis.swift
