import SwiftUI
import SwiftData

struct MealsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.timestamp, order: .reverse) private var meals: [Meal]
    @EnvironmentObject var syncMonitor: SyncMonitor
    @ObservedObject var settings = SettingsManager.shared
    @State private var showingAddMeal = false
    @State private var editingMeal: Meal?
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            List {
                // Hidden view that triggers refresh when sync occurs
                EmptyView().id(syncMonitor.refreshTrigger)
                ForEach(mealsByDay, id: \.day) { group in
                    Section {
                        ForEach(group.meals) { meal in
                            mealRow(meal)
                        }
                        .onDelete { offsets in
                            deleteMeals(offsets.map { group.meals[$0] })
                        }
                    } header: {
                        dayHeader(group.day, meals: group.meals)
                    }
                }
            }
            .navigationTitle("Meals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingAddMeal) {
            MealEditorView()
        }
        .sheet(item: $editingMeal) { meal in
            MealEditorView(meal: meal)
        }
    }
    
    private var mealsByDay: [(day: Date, meals: [Meal])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: meals) { calendar.startOfDay(for: $0.timestamp) }
        return grouped
            .map { (day: $0.key, meals: $0.value.sorted { $0.timestamp > $1.timestamp }) }
            .sorted { $0.day > $1.day }
    }
    
    private func dayHeader(_ day: Date, meals: [Meal]) -> some View {
        let total = meals.reduce(NutritionInfo.zero) { $0 + $1.totalNutrition }
        let calendar = Calendar.current
        let title: String
        if calendar.isDateInToday(day) {
            title = "Today"
        } else if calendar.isDateInYesterday(day) {
            title = "Yesterday"
        } else {
            title = day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        }
        return HStack {
            Text(title)
            Spacer()
            Text("C \(total.carbohydrates, specifier: "%.0f")g · P \(total.protein, specifier: "%.0f")g · \(total.calories, specifier: "%.0f") kcal")
                .monospacedDigit()
        }
    }
    
    @ViewBuilder
    private func mealRow(_ meal: Meal) -> some View {
        Button(action: {
            editingMeal = meal
        }) {
            HStack(spacing: 12) {
                // Show photo thumbnail if available
                if let photoData = meal.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(meal.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Show warning icon for incomplete meals
                        if meal.isIncomplete {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        
                        Spacer()
                        Text(meal.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                
                    if !(meal.foods?.isEmpty ?? true) {
                        Text("Foods: \((meal.foods ?? []).map { $0.name }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !(meal.drinks?.isEmpty ?? true) {
                        Text("Drinks: \((meal.drinks ?? []).map { $0.name }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Show incomplete warning
                    if meal.isIncomplete {
                        Text("⚠️ Add nutrition details")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Label("\(settings.formatNutritionalWeight(meal.totalNutrition.carbohydrates))\(settings.nutritionalWeightUnit)", systemImage: "leaf.fill")
                        Label("\(settings.formatNutritionalWeight(meal.totalNutrition.protein))\(settings.nutritionalWeightUnit)", systemImage: "scalemass.fill")
                        Label("\(meal.totalNutrition.calories, specifier: "%.0f")", systemImage: "flame.fill")
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .leading) {
            Button {
                cloneMeal(meal)
            } label: {
                Label("Clone", systemImage: "doc.on.doc")
            }
            .tint(.green)
        }
    }
    
    private func cloneMeal(_ meal: Meal) {
        // Create copies of all foods
        let clonedFoods = (meal.foods ?? []).map { originalFood in
            FoodItem(
                name: originalFood.name,
                weight: originalFood.weight,
                nutrition: originalFood.nutrition,
                timestamp: Date()
            )
        }
        
        // Create copies of all drinks
        let clonedDrinks = (meal.drinks ?? []).map { originalDrink in
            Drink(
                name: originalDrink.name,
                volume: originalDrink.volume,
                nutrition: originalDrink.nutrition,
                isAlcoholic: originalDrink.isAlcoholic,
                timestamp: Date()
            )
        }
        
        // Create new meal with current timestamp
        let clonedMeal = Meal(
            name: meal.name,
            foods: [],
            drinks: [],
            timestamp: Date(),
            photoData: meal.photoData
        )
        
        // Insert meal first
        modelContext.insert(clonedMeal)
        
        // Then insert and link foods and drinks
        for food in clonedFoods {
            modelContext.insert(food)
            food.meal = clonedMeal
        }
        for drink in clonedDrinks {
            modelContext.insert(drink)
            drink.meal = clonedMeal
        }
        
        clonedMeal.foods = clonedFoods
        clonedMeal.drinks = clonedDrinks
        
        try? modelContext.save()
    }
    
    private func deleteMeals(_ mealsToDelete: [Meal]) {
        for meal in mealsToDelete {
            modelContext.delete(meal)
        }
        do {
            try modelContext.save()
        } catch {
            print("❌ Error deleting meal: \(error)")
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        
        // Force a fetch from the persistent store
        do {
            let descriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            _ = try modelContext.fetch(descriptor)
            
            // Also fetch related objects
            let foodDescriptor = FetchDescriptor<FoodItem>()
            _ = try modelContext.fetch(foodDescriptor)
            
            let drinkDescriptor = FetchDescriptor<Drink>()
            _ = try modelContext.fetch(drinkDescriptor)
            
            print("🔄 Manual refresh completed - Found \(meals.count) meals")
        } catch {
            print("⚠️ Refresh error: \(error)")
        }
        
        // Small delay to show the refresh indicator
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        isRefreshing = false
    }
}
