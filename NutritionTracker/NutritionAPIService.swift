import Foundation

struct USDAFoodSearchResult: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable, Identifiable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]?
    
    var id: Int { fdcId }
    
    func toNutritionInfo() -> NutritionInfo {
        guard let nutrients = foodNutrients else {
            return NutritionInfo.zero
        }
        
        var carbs = 0.0
        var protein = 0.0
        var calories = 0.0
        
        for nutrient in nutrients {
            let name = nutrient.nutrientName.lowercased()
            let unit = nutrient.unitName?.lowercased() ?? ""
            
            // Match carbohydrates (nutrient ID 1005)
            if name.contains("carbohydrate") && carbs == 0 {
                carbs = nutrient.value ?? 0
            }
            
            // Match protein (nutrient ID 1003)
            if name.contains("protein") && protein == 0 {
                protein = nutrient.value ?? 0
            }
            
            // Match energy/calories (nutrient ID 1008)
            if (name.contains("energy") || name.contains("calorie")) && unit == "kcal" && calories == 0 {
                calories = nutrient.value ?? 0
            }
        }
        
        return NutritionInfo(carbohydrates: carbs, protein: protein, calories: calories)
    }
}

struct USDANutrient: Codable {
    let nutrientName: String
    let value: Double?
    let unitName: String?
}

enum NutritionAPIError: LocalizedError {
    case rateLimited
    
    var errorDescription: String? {
        "USDA rate limit reached. Add your own free API key in Settings, or try again later."
    }
}

class NutritionAPIService {
    static let shared = NutritionAPIService()
    
    // USDA FoodData Central API - free, no API key required for basic search
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    // Free personal keys: https://fdc.nal.usda.gov/api-key-signup.html
    // DEMO_KEY works without signup but is heavily rate-limited.
    private var apiKey: String {
        let key = SettingsManager.shared.usdaAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return key.isEmpty ? "DEMO_KEY" : key
    }
    
    func searchFood(query: String) async throws -> [USDAFood] {
        let apiKey = self.apiKey
        
        guard !query.isEmpty else { return [] }
        
        // Removed dataType filter to get all food types (Branded, Survey, Foundation, etc.)
        var components = URLComponents(string: "\(baseURL)/foods/search")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "20")
        ]
        // URLQueryItem leaves "+" unescaped, which the server would read as a space
        let encodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components?.percentEncodedQuery = encodedQuery
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if (response as? HTTPURLResponse)?.statusCode == 429 {
            throw NutritionAPIError.rateLimited
        }
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(USDAFoodSearchResult.self, from: data)
        return result.foods
    }
    
    func getFoodDetails(fdcId: Int) async throws -> USDAFood {
        let urlString = "\(baseURL)/food/\(fdcId)?api_key=\(self.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if (response as? HTTPURLResponse)?.statusCode == 429 {
            throw NutritionAPIError.rateLimited
        }
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let food = try JSONDecoder().decode(USDAFood.self, from: data)
        return food
    }
}
