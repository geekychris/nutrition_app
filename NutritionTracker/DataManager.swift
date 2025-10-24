import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var meals: [Meal] = []
    
    private let mealsKey = "saved_meals"
    
    init() {
        loadMeals()
    }
    
    func addMeal(_ meal: Meal) {
        meals.append(meal)
        saveMeals()
    }
    
    func deleteMeal(_ meal: Meal) {
        meals.removeAll { $0.id == meal.id }
        saveMeals()
    }
    
    func updateMeal(_ meal: Meal) {
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[index] = meal
            saveMeals()
        }
    }
    
    func getDailySummaries() -> [DailySummary] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: meals) { meal in
            calendar.startOfDay(for: meal.timestamp)
        }
        
        return grouped.map { date, meals in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return DailySummary(
                date: date,
                dateString: formatter.string(from: date),
                meals: meals.sorted { $0.timestamp < $1.timestamp }
            )
        }.sorted { $0.date > $1.date }
    }
    
    func getWeeklySummaries(weeks: Int = 4) -> [(weekStart: Date, nutrition: NutritionInfo)] {
        let calendar = Calendar.current
        let now = Date()
        
        var summaries: [(Date, NutritionInfo)] = []
        
        for weekOffset in 0..<weeks {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now),
                  let weekStartDay = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStartDay) else {
                continue
            }
            
            let weekMeals = meals.filter { meal in
                meal.timestamp >= weekStartDay && meal.timestamp < weekEnd
            }
            
            let totalNutrition = weekMeals.reduce(NutritionInfo.zero) { $0 + $1.totalNutrition }
            summaries.append((weekStartDay, totalNutrition))
        }
        
        return summaries.sorted { $0.0 < $1.0 }
    }
    
    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(encoded, forKey: mealsKey)
        }
    }
    
    private func loadMeals() {
        if let data = UserDefaults.standard.data(forKey: mealsKey),
           let decoded = try? JSONDecoder().decode([Meal].self, from: data) {
            meals = decoded
        }
    }
}
