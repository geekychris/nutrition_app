import SwiftUI
import SwiftData

@main
struct NutritionTrackerApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Meal.self,
                FoodItem.self,
                Drink.self
            ])
            
            // Simplified configuration - CloudKit will be enabled via container identifier
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
