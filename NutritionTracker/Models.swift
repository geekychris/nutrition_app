import Foundation
import SwiftData

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

@Model
final class FoodItem {
    var id: UUID = UUID()
    var name: String = ""
    var weight: Double = 0  // in grams
    var carbohydrates: Double = 0
    var protein: Double = 0
    var calories: Double = 0
    var timestamp: Date = Date()
    var meal: Meal?
    
    var nutrition: NutritionInfo {
        NutritionInfo(carbohydrates: carbohydrates, protein: protein, calories: calories)
    }
    
    init(name: String, weight: Double, nutrition: NutritionInfo, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.weight = weight
        self.carbohydrates = nutrition.carbohydrates
        self.protein = nutrition.protein
        self.calories = nutrition.calories
        self.timestamp = timestamp
    }
}

@Model
final class Drink {
    var id: UUID = UUID()
    var name: String = ""
    var volume: Double = 0  // in ml
    var carbohydrates: Double = 0
    var protein: Double = 0
    var calories: Double = 0
    var isAlcoholic: Bool = false
    var timestamp: Date = Date()
    var meal: Meal?
    
    var nutrition: NutritionInfo {
        NutritionInfo(carbohydrates: carbohydrates, protein: protein, calories: calories)
    }
    
    init(name: String, volume: Double, nutrition: NutritionInfo, isAlcoholic: Bool, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.volume = volume
        self.carbohydrates = nutrition.carbohydrates
        self.protein = nutrition.protein
        self.calories = nutrition.calories
        self.isAlcoholic = isAlcoholic
        self.timestamp = timestamp
    }
}

@Model
final class Meal {
    var id: UUID = UUID()
    var name: String = ""
    @Relationship(deleteRule: .cascade, inverse: \FoodItem.meal)
    var foods: [FoodItem]? = []
    @Relationship(deleteRule: .cascade, inverse: \Drink.meal)
    var drinks: [Drink]? = []
    var timestamp: Date = Date()
    var photoData: Data?  // Store image as Data for persistence
    
    var totalNutrition: NutritionInfo {
        let foodNutrition = (foods ?? []).reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        let drinkNutrition = (drinks ?? []).reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        return foodNutrition + drinkNutrition
    }
    
    var isIncomplete: Bool {
        // Meal is incomplete if it has a photo but no foods or drinks
        return photoData != nil && (foods?.isEmpty ?? true) && (drinks?.isEmpty ?? true)
    }
    
    init(name: String, foods: [FoodItem] = [], drinks: [Drink] = [], timestamp: Date = Date(), photoData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.foods = foods
        self.drinks = drinks
        self.timestamp = timestamp
        self.photoData = photoData
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
