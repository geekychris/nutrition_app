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
    @State private var photoChanged = false
    
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
        } else {
            _mealName = State(initialValue: Self.suggestedMealName(for: Date()))
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
                                photoChanged = true
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
            .onChange(of: mealPhoto) { _, _ in
                photoChanged = true
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
        .alert("Save Error", isPresented: Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })) {
            Button("OK") { saveError = nil }
        } message: {
            if let error = saveError {
                Text(error)
            }
        }
    }
    
    private static func suggestedMealName(for date: Date) -> String {
        switch Calendar.current.component(.hour, from: date) {
        case 4..<11: return "Breakfast"
        case 11..<15: return "Lunch"
        case 17..<22: return "Dinner"
        default: return "Snack"
        }
    }
    
    private static func encodePhoto(_ image: UIImage, maxDimension: CGFloat = 1600) -> Data? {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else {
            return image.jpegData(compressionQuality: 0.7)
        }
        let scale = maxDimension / longest
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.7)
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
        
        // Only re-encode the photo when it changed, so repeated edits don't degrade it.
        // Downscale first: full-resolution camera images bloat the store and CloudKit records.
        let photoData = photoChanged ? mealPhoto.flatMap { Self.encodePhoto($0) } : meal?.photoData
        
        if let existingMeal = meal {
            // Update existing meal
            existingMeal.name = mealName
            existingMeal.timestamp = mealDate
            if photoChanged {
                existingMeal.photoData = photoData
            }
            
            // Delete only the items the user removed. `foods`/`drinks` still hold the
            // meal's existing objects, so deleting all old items would delete those too.
            let keptFoodIDs = Set(foods.map(\.persistentModelID))
            for food in existingMeal.foods ?? [] where !keptFoodIDs.contains(food.persistentModelID) {
                modelContext.delete(food)
            }
            let keptDrinkIDs = Set(drinks.map(\.persistentModelID))
            for drink in existingMeal.drinks ?? [] where !keptDrinkIDs.contains(drink.persistentModelID) {
                modelContext.delete(drink)
            }
            
            // Insert newly added foods and drinks
            for food in foods where food.modelContext == nil {
                modelContext.insert(food)
            }
            for drink in drinks where drink.modelContext == nil {
                modelContext.insert(drink)
            }
            for food in foods { food.meal = existingMeal }
            for drink in drinks { drink.meal = existingMeal }
            
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
