import Foundation

struct NutritionInfo: Codable, Hashable {
    var carbohydrates: Double  // in grams
    var protein: Double        // in grams
    var calories: Double       // in kcal
    
    static var zero: NutritionInfo {
        NutritionInfo(carbohydrates: 0, protein: 0, calories: 0)
    }
    
    static func + (lhs: NutritionInfo, rhs: NutritionInfo) -> NutritionInfo {
        NutritionInfo(
            carbohydrates: lhs.carbohydrates + rhs.carbohydrates,
            protein: lhs.protein + rhs.protein,
            calories: lhs.calories + rhs.calories
        )
    }
}

struct FoodItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var weight: Double  // in grams
    var nutrition: NutritionInfo
    var timestamp: Date = Date()
}

struct Drink: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var volume: Double  // in ml
    var nutrition: NutritionInfo
    var isAlcoholic: Bool
    var timestamp: Date = Date()
}

struct Meal: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var foods: [FoodItem]
    var drinks: [Drink]
    var timestamp: Date = Date()
    
    var totalNutrition: NutritionInfo {
        let foodNutrition = foods.reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        let drinkNutrition = drinks.reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        return foodNutrition + drinkNutrition
    }
}

struct DailySummary: Identifiable {
    var id: String { dateString }
    var date: Date
    var dateString: String
    var meals: [Meal]
    
    var totalNutrition: NutritionInfo {
        meals.reduce(NutritionInfo.zero) { $0 + $1.totalNutrition }
    }
}
