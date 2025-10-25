import SwiftUI

struct AddDrinkView: View {
    @Binding var drinks: [Drink]
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = SettingsManager.shared
    
    @State private var name = ""
    @State private var volume = ""
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
                        TextField(settings.measurementUnit.volumeUnit, text: Binding(
                            get: { displayVolume },
                            set: { newValue in
                                // Convert displayed value to ml for storage
                                if let displayValue = Double(newValue) {
                                    let ml = settings.measurementUnit == .imperial
                                        ? settings.fluidOuncesToMl(displayValue)
                                        : displayValue
                                    volume = String(format: "%.0f", ml)
                                    if !carbs.isEmpty || !protein.isEmpty || !calories.isEmpty {
                                        recalculateNutrition()
                                    }
                                } else {
                                    volume = newValue
                                }
                            }
                        ))
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
    
    private var displayVolume: String {
        guard let volumeMl = Double(volume) else { return volume }
        
        switch settings.measurementUnit {
        case .metric:
            return String(format: "%.0f", volumeMl)
        case .imperial:
            return String(format: "%.1f", settings.mlToFluidOunces(volumeMl))
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        Double(volume) != nil &&
        Double(carbs) != nil &&
        Double(protein) != nil &&
        Double(calories) != nil
    }
    
    private func selectDrink(_ template: DrinkTemplate) {
        name = template.name
        isAlcoholic = template.isAlcoholic
        showingSuggestions = false
        
        // If volume is already entered, calculate nutrition
        if let volumeVal = Double(volume), volumeVal > 0 {
            let ratio = volumeVal / 100.0
            carbs = String(format: "%.1f", template.nutritionPer100ml.carbohydrates * ratio)
            protein = String(format: "%.1f", template.nutritionPer100ml.protein * ratio)
            calories = String(format: "%.0f", template.nutritionPer100ml.calories * ratio)
        } else {
            // Set values for 100ml by default
            volume = "100"
            carbs = String(format: "%.1f", template.nutritionPer100ml.carbohydrates)
            protein = String(format: "%.1f", template.nutritionPer100ml.protein)
            calories = String(format: "%.0f", template.nutritionPer100ml.calories)
        }
    }
    
    private func recalculateNutrition() {
        // Find if current name matches a template
        if let template = NutritionDatabase.shared.drinks.first(where: { $0.name == name }),
           let volumeVal = Double(volume), volumeVal > 0 {
            let ratio = volumeVal / 100.0
            carbs = String(format: "%.1f", template.nutritionPer100ml.carbohydrates * ratio)
            protein = String(format: "%.1f", template.nutritionPer100ml.protein * ratio)
            calories = String(format: "%.0f", template.nutritionPer100ml.calories * ratio)
        }
    }
    
    private func addDrink() {
        guard let volumeVal = Double(volume),
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
