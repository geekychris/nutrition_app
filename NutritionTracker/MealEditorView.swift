import SwiftUI

struct MealEditorView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var mealName = ""
    @State private var foods: [FoodItem] = []
    @State private var drinks: [Drink] = []
    @State private var showingAddFood = false
    @State private var showingAddDrink = false
    
    var meal: Meal?
    
    init(meal: Meal? = nil) {
        self.meal = meal
        if let meal = meal {
            _mealName = State(initialValue: meal.name)
            _foods = State(initialValue: meal.foods)
            _drinks = State(initialValue: meal.drinks)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Name")) {
                    TextField("e.g., Breakfast", text: $mealName)
                }
                
                Section(header: Text("Foods")) {
                    ForEach(foods) { food in
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .font(.headline)
                            Text("\(food.weight, specifier: "%.1f")g | C: \(food.nutrition.carbohydrates, specifier: "%.1f")g | P: \(food.nutrition.protein, specifier: "%.1f")g | Cal: \(food.nutrition.calories, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        foods.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Food") {
                        showingAddFood = true
                    }
                }
                
                Section(header: Text("Drinks")) {
                    ForEach(drinks) { drink in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(drink.name)
                                    .font(.headline)
                                if drink.isAlcoholic {
                                    Text("🍺")
                                        .font(.caption)
                                }
                            }
                            Text("\(drink.volume, specifier: "%.0f")ml | C: \(drink.nutrition.carbohydrates, specifier: "%.1f")g | P: \(drink.nutrition.protein, specifier: "%.1f")g | Cal: \(drink.nutrition.calories, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        drinks.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Drink") {
                        showingAddDrink = true
                    }
                }
                
                Section(header: Text("Total Nutrition")) {
                    let total = calculateTotal()
                    HStack {
                        Text("Carbohydrates:")
                        Spacer()
                        Text("\(total.carbohydrates, specifier: "%.1f")g")
                    }
                    HStack {
                        Text("Protein:")
                        Spacer()
                        Text("\(total.protein, specifier: "%.1f")g")
                    }
                    HStack {
                        Text("Calories:")
                        Spacer()
                        Text("\(total.calories, specifier: "%.0f") kcal")
                    }
                }
                
                Button(meal == nil ? "Save Meal" : "Update Meal") {
                    saveMeal()
                }
                .disabled(mealName.isEmpty || (foods.isEmpty && drinks.isEmpty))
            }
            .navigationTitle(meal == nil ? "New Meal" : "Edit Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView(foods: $foods)
            }
            .sheet(isPresented: $showingAddDrink) {
                AddDrinkView(drinks: $drinks)
            }
        }
    }
    
    private func calculateTotal() -> NutritionInfo {
        let foodTotal = foods.reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        let drinkTotal = drinks.reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        return foodTotal + drinkTotal
    }
    
    private func saveMeal() {
        if let existingMeal = meal {
            var updated = existingMeal
            updated.name = mealName
            updated.foods = foods
            updated.drinks = drinks
            dataManager.updateMeal(updated)
        } else {
            let newMeal = Meal(
                name: mealName,
                foods: foods,
                drinks: drinks
            )
            dataManager.addMeal(newMeal)
        }
        dismiss()
    }
}
