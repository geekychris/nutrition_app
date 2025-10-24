import SwiftUI

struct MealsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddMeal = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.meals.sorted(by: { $0.timestamp > $1.timestamp })) { meal in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(meal.name)
                                .font(.headline)
                            Spacer()
                            Text(meal.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !meal.foods.isEmpty {
                            Text("Foods: \(meal.foods.map { $0.name }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !meal.drinks.isEmpty {
                            Text("Drinks: \(meal.drinks.map { $0.name }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("\(meal.totalNutrition.carbohydrates, specifier: "%.1f")g", systemImage: "leaf.fill")
                            Label("\(meal.totalNutrition.protein, specifier: "%.1f")g", systemImage: "scalemass.fill")
                            Label("\(meal.totalNutrition.calories, specifier: "%.0f")", systemImage: "flame.fill")
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteMeal)
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
            .sheet(isPresented: $showingAddMeal) {
                MealEditorView()
            }
        }
    }
    
    private func deleteMeal(at offsets: IndexSet) {
        let sortedMeals = dataManager.meals.sorted(by: { $0.timestamp > $1.timestamp })
        for index in offsets {
            dataManager.deleteMeal(sortedMeals[index])
        }
    }
}
