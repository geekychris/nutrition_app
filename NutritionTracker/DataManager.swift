import Foundation
import SwiftUI
import SwiftData

class DataManager: ObservableObject {
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addMeal(_ meal: Meal) {
        modelContext.insert(meal)
        try? modelContext.save()
    }
    
    func deleteMeal(_ meal: Meal) {
        modelContext.delete(meal)
        try? modelContext.save()
    }
    
    func updateMeal(_ meal: Meal) {
        // SwiftData automatically tracks changes
        try? modelContext.save()
    }
    
    func getDailySummaries(meals: [Meal]) -> [DailySummary] {
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
    
    func getWeeklySummaries(meals: [Meal], weeks: Int = 4) -> [(weekStart: Date, nutrition: NutritionInfo)] {
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
}
