import SwiftUI

struct AddFoodView: View {
    @Binding var foods: [FoodItem]
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = SettingsManager.shared
    
    @State private var name = ""
    @State private var weightInput = "" // In the user's display unit (g or oz)
    @State private var carbs = ""
    @State private var protein = ""
    @State private var calories = ""
    @State private var showingSuggestions = false
    @State private var searchResults: [FoodTemplate] = []
    @State private var showingOnlineSearch = false
    @State private var onlineSearchQuery = ""
    @State private var onlineResults: [USDAFood] = []
    @State private var isSearching = false
    @State private var searchError: String?
    
    // Store base nutrition values per 100g for recalculation
    @State private var baseCarbsPer100g: Double?
    @State private var baseProteinPer100g: Double?
    @State private var baseCaloriesPer100g: Double?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    HStack {
                        Text("Name")
                            .frame(width: 80, alignment: .leading)
                        TextField("e.g., Eggs", text: $name)
                            .onChange(of: name) { oldValue, newValue in
                                searchResults = NutritionDatabase.shared.searchFoods(newValue)
                                showingSuggestions = !newValue.isEmpty && !searchResults.isEmpty
                            }
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
                    
                    HStack {
                        Text("Weight")
                            .frame(width: 80, alignment: .leading)
                        TextField(settings.measurementUnit.weightUnit, text: $weightInput)
                            .onChange(of: weightInput) { _, _ in
                                recalculateFromWeight()
                            }
                        .keyboardType(.decimalPad)
                        
                        Text(settings.measurementUnit.weightUnit)
                            .foregroundColor(.secondary)
                        
                        if hasBaseNutrition() {
                            Stepper("", value: Binding(
                                get: { Double(weightInput) ?? 0 },
                                set: { weightInput = Self.formatInput($0) }
                            ), in: displayWeightRange, step: displayWeightStep)
                            .labelsHidden()
                        }
                    }
                }
                
                Section(header: Text("Nutrition Information")) {
                    HStack {
                        Text("Carbs")
                            .frame(width: 80, alignment: .leading)
                        TextField("grams", text: $carbs)
                            .keyboardType(.decimalPad)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Protein")
                            .frame(width: 80, alignment: .leading)
                        TextField("grams", text: $protein)
                            .keyboardType(.decimalPad)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Calories")
                            .frame(width: 80, alignment: .leading)
                        TextField("kcal", text: $calories)
                            .keyboardType(.decimalPad)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        showingOnlineSearch = true
                        onlineSearchQuery = name
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search Online Database")
                            Spacer()
                            Image(systemName: "cloud")
                                .foregroundColor(.blue)
                        }
                    }
                } footer: {
                    Text("Search USDA FoodData Central for nutrition information")
                        .font(.caption)
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
            .sheet(isPresented: $showingOnlineSearch) {
                OnlineFoodSearchView(
                    searchQuery: $onlineSearchQuery,
                    onSelect: { usdaFood in
                        selectOnlineFood(usdaFood)
                        showingOnlineSearch = false
                    }
                )
            }
        }
    }
    
    /// Weight in grams parsed from the input field, converting from ounces when imperial.
    private var weightGrams: Double? {
        guard let value = Double(weightInput.replacingOccurrences(of: ",", with: ".")) else { return nil }
        return settings.measurementUnit == .imperial ? settings.ouncesToGrams(value) : value
    }
    
    private static func formatInput(_ value: Double) -> String {
        value.rounded() == value ? String(format: "%.0f", value) : String(format: "%.2f", value)
    }
    
    private var displayWeightRange: ClosedRange<Double> {
        switch settings.measurementUnit {
        case .metric:
            return 1...2000  // grams
        case .imperial:
            return 0.04...70.5  // ounces (1g to 2000g)
        }
    }
    
    private var displayWeightStep: Double {
        switch settings.measurementUnit {
        case .metric:
            return 10  // 10 grams
        case .imperial:
            return 0.5  // 0.5 ounces
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        (weightGrams ?? 0) > 0 &&
        Double(carbs) != nil &&
        Double(protein) != nil &&
        Double(calories) != nil
    }
    
    
    private func hasBaseNutrition() -> Bool {
        return baseCarbsPer100g != nil && baseProteinPer100g != nil && baseCaloriesPer100g != nil
    }
    
    private func recalculateFromWeight() {
        guard let weightVal = weightGrams, weightVal > 0,
              let baseCarbsPer100g = baseCarbsPer100g,
              let baseProteinPer100g = baseProteinPer100g,
              let baseCaloriesPer100g = baseCaloriesPer100g else {
            return
        }
        
        let ratio = weightVal / 100.0
        carbs = String(format: "%.1f", baseCarbsPer100g * ratio)
        protein = String(format: "%.1f", baseProteinPer100g * ratio)
        calories = String(format: "%.0f", baseCaloriesPer100g * ratio)
    }
    
    private func selectFood(_ template: FoodTemplate) {
        name = template.name
        showingSuggestions = false
        
        // Store base nutrition values per 100g
        baseCarbsPer100g = template.nutritionPer100g.carbohydrates
        baseProteinPer100g = template.nutritionPer100g.protein
        baseCaloriesPer100g = template.nutritionPer100g.calories
        
        if (weightGrams ?? 0) <= 0 {
            // Default to 100 g (or the nearest round ounce amount)
            weightInput = settings.measurementUnit == .imperial ? "3.5" : "100"
        }
        recalculateFromWeight()
    }
    
    private func selectOnlineFood(_ usdaFood: USDAFood) {
        name = usdaFood.description
        showingSuggestions = false
        
        let nutritionPer100g = usdaFood.toNutritionInfo()
        
        // Store base nutrition values per 100g
        baseCarbsPer100g = nutritionPer100g.carbohydrates
        baseProteinPer100g = nutritionPer100g.protein
        baseCaloriesPer100g = nutritionPer100g.calories
        
        if (weightGrams ?? 0) <= 0 {
            // Default to 100 g (or the nearest round ounce amount)
            weightInput = settings.measurementUnit == .imperial ? "3.5" : "100"
        }
        recalculateFromWeight()
    }
    
    private func addFood() {
        guard let weightVal = weightGrams,
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
