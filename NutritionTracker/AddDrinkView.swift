import SwiftUI

struct AddDrinkView: View {
    @Binding var drinks: [Drink]
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = SettingsManager.shared
    
    @State private var name = ""
    @State private var volumeInput = "" // In the user's display unit (ml or fl oz)
    @State private var carbs = ""
    @State private var protein = ""
    @State private var calories = ""
    @State private var isAlcoholic = false
    @State private var showingSuggestions = false
    @State private var searchResults: [DrinkTemplate] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Drink Details")) {
                    TextField("Name (e.g., Beer)", text: $name)
                        .onChange(of: name) { oldValue, newValue in
                            searchResults = NutritionDatabase.shared.searchDrinks(newValue)
                            showingSuggestions = !newValue.isEmpty && !searchResults.isEmpty
                        }
                    
                    if showingSuggestions {
                        ForEach(searchResults.prefix(5)) { template in
                            Button(action: {
                                selectDrink(template)
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(template.name)
                                                .foregroundColor(.primary)
                                            if template.isAlcoholic {
                                                Text("🍺")
                                                    .font(.caption)
                                            }
                                        }
                                        Text("\(template.category) • \(template.nutritionPer100ml.calories, specifier: "%.0f") cal/100ml")
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
                    
                    HStack {
                        TextField(settings.measurementUnit.volumeUnit, text: $volumeInput)
                            .onChange(of: volumeInput) { _, _ in
                                recalculateNutrition()
                            }
                        .keyboardType(.decimalPad)
                        
                        Text(settings.measurementUnit.volumeUnit)
                            .foregroundColor(.secondary)
                    }
                    Toggle("Alcoholic", isOn: $isAlcoholic)
                }
                
                Section(header: Text("Nutrition Information")) {
                    TextField("Carbohydrates (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Calories (kcal)", text: $calories)
                        .keyboardType(.decimalPad)
                }
                
                Button("Add Drink") {
                    addDrink()
                }
                .disabled(!isValid)
            }
            .navigationTitle("Add Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    /// Volume in ml parsed from the input field, converting from fl oz when imperial.
    private var volumeMl: Double? {
        guard let value = Double(volumeInput.replacingOccurrences(of: ",", with: ".")) else { return nil }
        return settings.measurementUnit == .imperial ? settings.fluidOuncesToMl(value) : value
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        (volumeMl ?? 0) > 0 &&
        Double(carbs) != nil &&
        Double(protein) != nil &&
        Double(calories) != nil
    }
    
    private func selectDrink(_ template: DrinkTemplate) {
        name = template.name
        isAlcoholic = template.isAlcoholic
        showingSuggestions = false
        
        if (volumeMl ?? 0) <= 0 {
            // Default to 100 ml (or a round fl oz amount)
            volumeInput = settings.measurementUnit == .imperial ? "3.4" : "100"
        }
        recalculateNutrition()
    }
    
    private func recalculateNutrition() {
        // Find if current name matches a template
        if let template = NutritionDatabase.shared.drinks.first(where: { $0.name == name }),
           let volumeVal = volumeMl, volumeVal > 0 {
            let ratio = volumeVal / 100.0
            carbs = String(format: "%.1f", template.nutritionPer100ml.carbohydrates * ratio)
            protein = String(format: "%.1f", template.nutritionPer100ml.protein * ratio)
            calories = String(format: "%.0f", template.nutritionPer100ml.calories * ratio)
        }
    }
    
    private func addDrink() {
        guard let volumeVal = volumeMl,
              let carbsVal = Double(carbs),
              let proteinVal = Double(protein),
              let caloriesVal = Double(calories) else {
            return
        }
        
        let drink = Drink(
            name: name,
            volume: volumeVal,
            nutrition: NutritionInfo(
                carbohydrates: carbsVal,
                protein: proteinVal,
                calories: caloriesVal
            ),
            isAlcoholic: isAlcoholic
        )
        
        drinks.append(drink)
        dismiss()
    }
}
