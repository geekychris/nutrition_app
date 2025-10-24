import SwiftUI

struct AddFoodView: View {
    @Binding var foods: [FoodItem]
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var weight = ""
    @State private var carbs = ""
    @State private var protein = ""
    @State private var calories = ""
    @State private var showingSuggestions = false
    @State private var searchResults: [FoodTemplate] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Name (e.g., Eggs)", text: $name)
                        .onChange(of: name) { oldValue, newValue in
                            searchResults = NutritionDatabase.shared.searchFoods(newValue)
                            showingSuggestions = !newValue.isEmpty && !searchResults.isEmpty
                        }
                    
                    if showingSuggestions {
                        ForEach(searchResults.prefix(5)) { template in
                            Button(action: {
                                selectFood(template)
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(template.name)
                                            .foregroundColor(.primary)
                                        Text("\(template.category) • \(template.nutritionPer100g.calories, specifier: "%.0f") cal/100g")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    TextField("Weight (grams)", text: $weight)
                        .keyboardType(.decimalPad)
                        .onChange(of: weight) { oldValue, newValue in
                            if !carbs.isEmpty || !protein.isEmpty || !calories.isEmpty {
                                recalculateNutrition()
                            }
                        }
                }
                
                Section(header: Text("Nutrition Information")) {
                    TextField("Carbohydrates (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Calories (kcal)", text: $calories)
                        .keyboardType(.decimalPad)
                }
                
                Button("Add Food") {
                    addFood()
                }
                .disabled(!isValid)
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        Double(weight) != nil &&
        Double(carbs) != nil &&
        Double(protein) != nil &&
        Double(calories) != nil
    }
    
    private func selectFood(_ template: FoodTemplate) {
        name = template.name
        showingSuggestions = false
        
        // If weight is already entered, calculate nutrition
        if let weightVal = Double(weight), weightVal > 0 {
            let ratio = weightVal / 100.0
            carbs = String(format: "%.1f", template.nutritionPer100g.carbohydrates * ratio)
            protein = String(format: "%.1f", template.nutritionPer100g.protein * ratio)
            calories = String(format: "%.0f", template.nutritionPer100g.calories * ratio)
        } else {
            // Set values for 100g by default
            weight = "100"
            carbs = String(format: "%.1f", template.nutritionPer100g.carbohydrates)
            protein = String(format: "%.1f", template.nutritionPer100g.protein)
            calories = String(format: "%.0f", template.nutritionPer100g.calories)
        }
    }
    
    private func recalculateNutrition() {
        // Find if current name matches a template
        if let template = NutritionDatabase.shared.foods.first(where: { $0.name == name }),
           let weightVal = Double(weight), weightVal > 0 {
            let ratio = weightVal / 100.0
            carbs = String(format: "%.1f", template.nutritionPer100g.carbohydrates * ratio)
            protein = String(format: "%.1f", template.nutritionPer100g.protein * ratio)
            calories = String(format: "%.0f", template.nutritionPer100g.calories * ratio)
        }
    }
    
    private func addFood() {
        guard let weightVal = Double(weight),
              let carbsVal = Double(carbs),
              let proteinVal = Double(protein),
              let caloriesVal = Double(calories) else {
            return
        }
        
        let food = FoodItem(
            name: name,
            weight: weightVal,
            nutrition: NutritionInfo(
                carbohydrates: carbsVal,
                protein: proteinVal,
                calories: caloriesVal
            )
        )
        
        foods.append(food)
        dismiss()
    }
}
