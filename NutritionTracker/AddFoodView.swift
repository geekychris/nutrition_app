import SwiftUI

struct AddFoodView: View {
    @Binding var foods: [FoodItem]
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = SettingsManager.shared
    
    @State private var name = ""
    @State private var weight = "" // Always stored in grams internally
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
                        TextField(settings.measurementUnit.weightUnit, text: Binding(
                            get: { displayWeight },
                            set: { newValue in
                                // Convert displayed value to grams for storage
                                if let displayValue = Double(newValue) {
                                    let grams = settings.measurementUnit == .imperial 
                                        ? settings.ouncesToGrams(displayValue)
                                        : displayValue
                                    weight = String(format: "%.1f", grams)
                                    recalculateFromWeight()
                                } else {
                                    weight = newValue
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        
                        Text(settings.measurementUnit.weightUnit)
                            .foregroundColor(.secondary)
                        
                        if let weightVal = Double(weight), hasBaseNutrition() {
                            Stepper("", value: Binding(
                                get: { 
                                    settings.measurementUnit == .imperial 
                                        ? settings.gramsToOunces(weightVal)
                                        : weightVal
                                },
                                set: { newWeight in
                                    let grams = settings.measurementUnit == .imperial
                                        ? settings.ouncesToGrams(newWeight)
                                        : newWeight
                                    weight = String(format: "%.1f", grams)
                                    recalculateFromWeight()
                                }
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
    
    private var displayWeight: String {
        guard let weightGrams = Double(weight) else { return weight }
        
        switch settings.measurementUnit {
        case .metric:
            return String(format: "%.1f", weightGrams)
        case .imperial:
            return String(format: "%.2f", settings.gramsToOunces(weightGrams))
        }
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
        Double(weight) != nil &&
        Double(carbs) != nil &&
        Double(protein) != nil &&
        Double(calories) != nil
    }
    
    
    private func hasBaseNutrition() -> Bool {
        return baseCarbsPer100g != nil && baseProteinPer100g != nil && baseCaloriesPer100g != nil
    }
    
    private func recalculateFromWeight() {
        guard let weightVal = Double(weight), weightVal > 0,
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
    
    private func selectOnlineFood(_ usdaFood: USDAFood) {
        name = usdaFood.description
        showingSuggestions = false
        
        let nutritionPer100g = usdaFood.toNutritionInfo()
        
        // Store base nutrition values per 100g
        baseCarbsPer100g = nutritionPer100g.carbohydrates
        baseProteinPer100g = nutritionPer100g.protein
        baseCaloriesPer100g = nutritionPer100g.calories
        
        // If weight is already entered, calculate nutrition
        if let weightVal = Double(weight), weightVal > 0 {
            let ratio = weightVal / 100.0
            carbs = String(format: "%.1f", nutritionPer100g.carbohydrates * ratio)
            protein = String(format: "%.1f", nutritionPer100g.protein * ratio)
            calories = String(format: "%.0f", nutritionPer100g.calories * ratio)
        } else {
            // Set values for 100g by default
            weight = "100"
            carbs = String(format: "%.1f", nutritionPer100g.carbohydrates)
            protein = String(format: "%.1f", nutritionPer100g.protein)
            calories = String(format: "%.0f", nutritionPer100g.calories)
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
