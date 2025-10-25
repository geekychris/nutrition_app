import SwiftUI
import SwiftData

struct MealEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = SettingsManager.shared
    
    @State private var mealName = ""
    @State private var mealDate = Date()
    @State private var foods: [FoodItem] = []
    @State private var drinks: [Drink] = []
    @State private var showingAddFood = false
    @State private var showingAddDrink = false
    @State private var mealPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var showingPhotoOptions = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var saveError: String?
    
    var meal: Meal?
    
    init(meal: Meal? = nil) {
        self.meal = meal
        if let meal = meal {
            _mealName = State(initialValue: meal.name)
            _mealDate = State(initialValue: meal.timestamp)
            _foods = State(initialValue: meal.foods ?? [])
            _drinks = State(initialValue: meal.drinks ?? [])
            if let photoData = meal.photoData, let image = UIImage(data: photoData) {
                _mealPhoto = State(initialValue: image)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Details")) {
                    TextField("Meal Name (e.g., Breakfast)", text: $mealName)
                    
                    DatePicker(
                        "Date",
                        selection: $mealDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section(header: Text("Photo")) {
                    if let photo = mealPhoto {
                        VStack {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            
                            Button("Remove Photo", role: .destructive) {
                                mealPhoto = nil
                            }
                            .font(.caption)
                        }
                    } else {
                        Button(action: {
                            showingPhotoOptions = true
                        }) {
                            Label("Add Photo", systemImage: "camera")
                        }
                    }
                }
                
                Section(header: Text("Foods")) {
                    ForEach(foods) { food in
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .font(.headline)
                            Text("\(settings.formatWeightWithUnit(food.weight)) | C: \(settings.formatNutritionalWeight(food.nutrition.carbohydrates))\(settings.nutritionalWeightUnit) | P: \(settings.formatNutritionalWeight(food.nutrition.protein))\(settings.nutritionalWeightUnit) | Cal: \(food.nutrition.calories, specifier: "%.0f")")
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
                            Text("\(settings.formatVolumeWithUnit(drink.volume)) | C: \(settings.formatNutritionalWeight(drink.nutrition.carbohydrates))\(settings.nutritionalWeightUnit) | P: \(settings.formatNutritionalWeight(drink.nutrition.protein))\(settings.nutritionalWeightUnit) | Cal: \(drink.nutrition.calories, specifier: "%.0f")")
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
                        Text("\(settings.formatNutritionalWeight(total.carbohydrates)) \(settings.nutritionalWeightUnit)")
                    }
                    HStack {
                        Text("Protein:")
                        Spacer()
                        Text("\(settings.formatNutritionalWeight(total.protein)) \(settings.nutritionalWeightUnit)")
                    }
                    HStack {
                        Text("Calories:")
                        Spacer()
                        Text("\(total.calories, specifier: "%.0f") kcal")
                    }
                }
                
                Button(meal == nil ? "Save Meal" : "Update Meal") {
                    print("🔘 Save button tapped!")
                    saveMeal()
                }
                .disabled(mealName.isEmpty || (foods.isEmpty && drinks.isEmpty && mealPhoto == nil))
                .onAppear {
                    print("📋 MealEditorView appeared - Editing: \(meal != nil)")
                }
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
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $mealPhoto, sourceType: imageSourceType)
            }
            .confirmationDialog("Add Photo", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Photo") {
                        imageSourceType = .camera
                        showingImagePicker = true
                    }
                }
                Button("Choose from Library") {
                    imageSourceType = .photoLibrary
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .alert("Save Error", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: {
            if let error = saveError {
                Text(error)
            }
        }
    }
    
    private func calculateTotal() -> NutritionInfo {
        let foodTotal = foods.reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        let drinkTotal = drinks.reduce(NutritionInfo.zero) { $0 + $1.nutrition }
        return foodTotal + drinkTotal
    }
    
    private func saveMeal() {
        print("🚀 saveMeal() called")
        print("📝 Meal name: \(mealName)")
        print("🍽️ Foods: \(foods.count), Drinks: \(drinks.count)")
        
        // Convert photo to Data
        let photoData = mealPhoto?.jpegData(compressionQuality: 0.7)
        
        if let existingMeal = meal {
            // Update existing meal
            existingMeal.name = mealName
            existingMeal.timestamp = mealDate
            existingMeal.photoData = photoData
            
            // Remove old foods and drinks
            if let oldFoods = existingMeal.foods {
                for food in oldFoods {
                    modelContext.delete(food)
                }
            }
            if let oldDrinks = existingMeal.drinks {
                for drink in oldDrinks {
                    modelContext.delete(drink)
                }
            }
            
            // Insert new foods and drinks
            for food in foods {
                modelContext.insert(food)
                food.meal = existingMeal
            }
            for drink in drinks {
                modelContext.insert(drink)
                drink.meal = existingMeal
            }
            
            existingMeal.foods = foods
            existingMeal.drinks = drinks
        } else {
            // Create new meal
            let newMeal = Meal(
                name: mealName,
                foods: [],
                drinks: [],
                timestamp: mealDate,
                photoData: photoData
            )
            
            // Insert meal first
            modelContext.insert(newMeal)
            
            // Then insert and link foods and drinks
            for food in foods {
                modelContext.insert(food)
                food.meal = newMeal
            }
            for drink in drinks {
                modelContext.insert(drink)
                drink.meal = newMeal
            }
            
            newMeal.foods = foods
            newMeal.drinks = drinks
        }
        
        do {
            try modelContext.save()
            print("💾 Meal saved successfully: \"\(mealName)\" with \(foods.count) foods and \(drinks.count) drinks")
            print("✅ ModelContext has changes: \(modelContext.hasChanges)")
            dismiss()
        } catch {
            let errorMessage = "Failed to save: \(error.localizedDescription)"
            print("❌ Error saving meal: \(error)")
            saveError = errorMessage
        }
    }
}
