import Foundation
import UIKit
import Combine

class OpenAIService {
    static let shared = OpenAIService()
    
    // Replace with your actual API key
    private let apiKey = "YOUR_OPENAI_API_KEY"
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
            "model": "gpt-4-vision-preview",
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Parse the JSON response from the content
                    if let analysis = self.parseAnalysisFromResponse(content) {
                        completion(.success(analysis))
                    } else {
                        completion(.failure(OpenAIError.parsingFailed))
                    }
                } else {
                    completion(.failure(OpenAIError.invalidResponse))
                }
            } catch {
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
        // Extract JSON from the response
        let jsonPattern = "\\{[\\s\\S]*\\}"
        guard let regex = try? NSRegularExpression(pattern: jsonPattern),
              let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
              let range = Range(match.range, in: response) else {
            return nil
        }
        
        let jsonString = String(response[range])
        
        do {
            if let jsonData = jsonString.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                
                // Extract values from JSON
                let ingredients = (json["ingredients"] as? [String]) ?? []
                let calories = (json["calories"] as? Double) ?? 0.0
                let protein = (json["protein"] as? Double) ?? 0.0
                let carbs = (json["carbs"] as? Double) ?? 0.0
                let fat = (json["fat"] as? Double) ?? 0.0
                let glycemicIndex = (json["glycemicIndex"] as? String) ?? "Unknown"
                let diabeticFriendly = (json["diabeticFriendly"] as? Bool) ?? false
                let healthRecommendations = (json["healthRecommendations"] as? String) ?? ""
                
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
            }
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
        
        return nil
    }
}

// MARK: - Models

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

// MARK: - Errors

enum OpenAIError: Error {
    case imageConversionFailed
    case jsonEncodingFailed
    case noDataReceived
    case invalidResponse
    case parsingFailed
}
