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

class NutritionAPIService {
    static let shared = NutritionAPIService()
    
    // USDA FoodData Central API - free, no API key required for basic search
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    func searchFood(query: String) async throws -> [USDAFood] {
        // Note: For production, you should get a free API key from https://fdc.nal.usda.gov/api-key-signup.html
        // For now, using DEMO_KEY which has limited requests
        let apiKey = "DEMO_KEY"
        
        guard !query.isEmpty else { return [] }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        // Removed dataType filter to get all food types (Branded, Survey, Foundation, etc.)
        let urlString = "\(baseURL)/foods/search?api_key=\(apiKey)&query=\(encodedQuery)&pageSize=20"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(USDAFoodSearchResult.self, from: data)
        return result.foods
    }
    
    func getFoodDetails(fdcId: Int) async throws -> USDAFood {
        let apiKey = "DEMO_KEY"
        let urlString = "\(baseURL)/food/\(fdcId)?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let food = try JSONDecoder().decode(USDAFood.self, from: data)
        return food
    }
}
