import SwiftUI

struct MealsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var settings = SettingsManager.shared
    @State private var showingAddMeal = false
    @State private var editingMeal: Meal?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.meals.sorted(by: { $0.timestamp > $1.timestamp })) { meal in
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
            .sheet(item: $editingMeal) { meal in
                MealEditorView(meal: meal)
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
