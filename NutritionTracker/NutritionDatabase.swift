import Foundation

struct FoodTemplate: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var nutritionPer100g: NutritionInfo
    var category: String
}

struct DrinkTemplate: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var nutritionPer100ml: NutritionInfo
    var category: String
    var isAlcoholic: Bool
}

class NutritionDatabase {
    static let shared = NutritionDatabase()
    
    let foods: [FoodTemplate]
    
    init() {
        self.foods = NutritionDatabase.loadFoodsFromCSV()
    }
    
    private static func loadFoodsFromCSV() -> [FoodTemplate] {
        var loadedFoods: [FoodTemplate] = []
        
        // Try multiple paths for the dataset directory
        var datasetPath: String?
        
        // First try: Bundle resources (for production builds)
        if let bundlePath = Bundle.main.resourcePath {
            let bundleDatasetPath = bundlePath + "/dataset"
            if FileManager.default.fileExists(atPath: bundleDatasetPath) {
                datasetPath = bundleDatasetPath
            }
        }
        
        // Second try: Relative to source code (for development)
        if datasetPath == nil {
            let currentFile = #file
            let currentDirectory = (currentFile as NSString).deletingLastPathComponent
            let projectDatasetPath = (currentDirectory as NSString).deletingLastPathComponent + "/dataset"
            if FileManager.default.fileExists(atPath: projectDatasetPath) {
                datasetPath = projectDatasetPath
            }
        }
        
        guard let finalDatasetPath = datasetPath else {
            print("Error: Could not find dataset directory")
            return getFallbackFoods()
        }
        
        // List of CSV files to load
        let csvFiles = ["FOOD-DATA-GROUP1.csv", "FOOD-DATA-GROUP2.csv", "FOOD-DATA-GROUP3.csv", "FOOD-DATA-GROUP4.csv", "FOOD-DATA-GROUP5.csv"]
        
        for csvFile in csvFiles {
            let filePath = finalDatasetPath + "/" + csvFile
            
            guard let csvContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
                print("Warning: Could not read file \(csvFile)")
                continue
            }
            
            let rows = csvContent.components(separatedBy: "\n")
            
            // Skip header row (index 0) and process data rows
            for (index, row) in rows.enumerated() {
                if index == 0 || row.trimmingCharacters(in: .whitespaces).isEmpty {
                    continue
                }
                
                let columns = parseCSVRow(row)
                
                // CSV format: ,Unnamed: 0,food,Caloric Value,Fat,...,Carbohydrates,Sugars,Protein,...
                // Indices: 0(empty), 1(index), 2(food name), 3(calories), 4-7(fats), 8(carbs), 9(sugars), 10(protein)
                if columns.count > 10 {
                    let foodName = columns[2].trimmingCharacters(in: .whitespaces)
                    
                    if let calories = Double(columns[3]),
                       let carbs = Double(columns[8]),
                       let protein = Double(columns[10]) {
                        
                        let category = categorizeFood(name: foodName, carbs: carbs, protein: protein)
                        
                        let food = FoodTemplate(
                            name: foodName.capitalized,
                            nutritionPer100g: NutritionInfo(
                                carbohydrates: carbs,
                                protein: protein,
                                calories: calories
                            ),
                            category: category
                        )
                        
                        loadedFoods.append(food)
                    }
                }
            }
        }
        
        if loadedFoods.isEmpty {
            print("Warning: No foods loaded from CSV, using fallback data")
            return getFallbackFoods()
        }
        
        print("Successfully loaded \(loadedFoods.count) foods from CSV files")
        return loadedFoods
    }
    
    private static func parseCSVRow(_ row: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        columns.append(currentColumn)
        
        return columns
    }
    
    private static func categorizeFood(name: String, carbs: Double, protein: Double) -> String {
        let lowercaseName = name.lowercased()
        
        // Check for specific food types by name
        if lowercaseName.contains("chicken") || lowercaseName.contains("beef") || 
           lowercaseName.contains("pork") || lowercaseName.contains("turkey") ||
           lowercaseName.contains("fish") || lowercaseName.contains("salmon") ||
           lowercaseName.contains("tuna") || lowercaseName.contains("egg") ||
           lowercaseName.contains("tofu") || lowercaseName.contains("meat") {
            return "Protein"
        }
        
        if lowercaseName.contains("rice") || lowercaseName.contains("pasta") ||
           lowercaseName.contains("bread") || lowercaseName.contains("potato") ||
           lowercaseName.contains("oat") || lowercaseName.contains("cereal") ||
           lowercaseName.contains("quinoa") || lowercaseName.contains("noodle") {
            return "Carbs"
        }
        
        if lowercaseName.contains("apple") || lowercaseName.contains("banana") ||
           lowercaseName.contains("orange") || lowercaseName.contains("berry") ||
           lowercaseName.contains("grape") || lowercaseName.contains("melon") ||
           lowercaseName.contains("peach") || lowercaseName.contains("pear") ||
           lowercaseName.contains("fruit") {
            return "Fruits"
        }
        
        if lowercaseName.contains("cheese") || lowercaseName.contains("milk") ||
           lowercaseName.contains("yogurt") || lowercaseName.contains("butter") ||
           lowercaseName.contains("cream") {
            return "Dairy"
        }
        
        if lowercaseName.contains("almond") || lowercaseName.contains("peanut") ||
           lowercaseName.contains("walnut") || lowercaseName.contains("nut") ||
           lowercaseName.contains("seed") {
            return "Nuts"
        }
        
        // Categorize by nutritional content
        if protein >= 10 && carbs < 15 {
            return "Protein"
        } else if carbs >= 20 {
            return "Carbs"
        } else if carbs < 10 && protein < 5 {
            return "Vegetables"
        }
        
        return "Other"
    }
    
    private static func getFallbackFoods() -> [FoodTemplate] {
        return [
        // Proteins
        FoodTemplate(name: "Eggs", nutritionPer100g: NutritionInfo(carbohydrates: 1.1, protein: 13.0, calories: 155), category: "Protein"),
        FoodTemplate(name: "Chicken Breast", nutritionPer100g: NutritionInfo(carbohydrates: 0, protein: 31.0, calories: 165), category: "Protein"),
        FoodTemplate(name: "Salmon", nutritionPer100g: NutritionInfo(carbohydrates: 0, protein: 20.0, calories: 208), category: "Protein"),
        FoodTemplate(name: "Tuna", nutritionPer100g: NutritionInfo(carbohydrates: 0, protein: 30.0, calories: 132), category: "Protein"),
        FoodTemplate(name: "Beef Steak", nutritionPer100g: NutritionInfo(carbohydrates: 0, protein: 26.0, calories: 271), category: "Protein"),
        FoodTemplate(name: "Pork Chop", nutritionPer100g: NutritionInfo(carbohydrates: 0, protein: 27.0, calories: 242), category: "Protein"),
        FoodTemplate(name: "Turkey Breast", nutritionPer100g: NutritionInfo(carbohydrates: 0, protein: 30.0, calories: 135), category: "Protein"),
        FoodTemplate(name: "Ham", nutritionPer100g: NutritionInfo(carbohydrates: 1.5, protein: 22.0, calories: 145), category: "Protein"),
        FoodTemplate(name: "Bacon", nutritionPer100g: NutritionInfo(carbohydrates: 1.4, protein: 37.0, calories: 541), category: "Protein"),
        FoodTemplate(name: "Tofu", nutritionPer100g: NutritionInfo(carbohydrates: 1.9, protein: 8.0, calories: 76), category: "Protein"),
        
        // Vegetables
        FoodTemplate(name: "Broccoli", nutritionPer100g: NutritionInfo(carbohydrates: 7.0, protein: 2.8, calories: 34), category: "Vegetables"),
        FoodTemplate(name: "Brussel Sprouts", nutritionPer100g: NutritionInfo(carbohydrates: 9.0, protein: 3.4, calories: 43), category: "Vegetables"),
        FoodTemplate(name: "Spinach", nutritionPer100g: NutritionInfo(carbohydrates: 3.6, protein: 2.9, calories: 23), category: "Vegetables"),
        FoodTemplate(name: "Carrots", nutritionPer100g: NutritionInfo(carbohydrates: 10.0, protein: 0.9, calories: 41), category: "Vegetables"),
        FoodTemplate(name: "Cauliflower", nutritionPer100g: NutritionInfo(carbohydrates: 5.0, protein: 1.9, calories: 25), category: "Vegetables"),
        FoodTemplate(name: "Green Beans", nutritionPer100g: NutritionInfo(carbohydrates: 7.0, protein: 1.8, calories: 31), category: "Vegetables"),
        FoodTemplate(name: "Asparagus", nutritionPer100g: NutritionInfo(carbohydrates: 3.9, protein: 2.2, calories: 20), category: "Vegetables"),
        FoodTemplate(name: "Bell Pepper", nutritionPer100g: NutritionInfo(carbohydrates: 6.0, protein: 1.0, calories: 31), category: "Vegetables"),
        FoodTemplate(name: "Tomato", nutritionPer100g: NutritionInfo(carbohydrates: 3.9, protein: 0.9, calories: 18), category: "Vegetables"),
        FoodTemplate(name: "Cucumber", nutritionPer100g: NutritionInfo(carbohydrates: 3.6, protein: 0.7, calories: 16), category: "Vegetables"),
        FoodTemplate(name: "Lettuce", nutritionPer100g: NutritionInfo(carbohydrates: 2.9, protein: 1.4, calories: 15), category: "Vegetables"),
        
        // Carbs
        FoodTemplate(name: "White Rice", nutritionPer100g: NutritionInfo(carbohydrates: 28.0, protein: 2.7, calories: 130), category: "Carbs"),
        FoodTemplate(name: "Brown Rice", nutritionPer100g: NutritionInfo(carbohydrates: 23.0, protein: 2.6, calories: 111), category: "Carbs"),
        FoodTemplate(name: "Pasta", nutritionPer100g: NutritionInfo(carbohydrates: 25.0, protein: 5.0, calories: 131), category: "Carbs"),
        FoodTemplate(name: "Bread (White)", nutritionPer100g: NutritionInfo(carbohydrates: 49.0, protein: 9.0, calories: 265), category: "Carbs"),
        FoodTemplate(name: "Bread (Whole Wheat)", nutritionPer100g: NutritionInfo(carbohydrates: 41.0, protein: 13.0, calories: 247), category: "Carbs"),
        FoodTemplate(name: "Oatmeal", nutritionPer100g: NutritionInfo(carbohydrates: 12.0, protein: 2.5, calories: 71), category: "Carbs"),
        FoodTemplate(name: "Quinoa", nutritionPer100g: NutritionInfo(carbohydrates: 21.0, protein: 4.4, calories: 120), category: "Carbs"),
        FoodTemplate(name: "Potato", nutritionPer100g: NutritionInfo(carbohydrates: 17.0, protein: 2.0, calories: 77), category: "Carbs"),
        FoodTemplate(name: "Sweet Potato", nutritionPer100g: NutritionInfo(carbohydrates: 20.0, protein: 1.6, calories: 86), category: "Carbs"),
        
        // Fruits
        FoodTemplate(name: "Apple", nutritionPer100g: NutritionInfo(carbohydrates: 14.0, protein: 0.3, calories: 52), category: "Fruits"),
        FoodTemplate(name: "Banana", nutritionPer100g: NutritionInfo(carbohydrates: 23.0, protein: 1.1, calories: 89), category: "Fruits"),
        FoodTemplate(name: "Orange", nutritionPer100g: NutritionInfo(carbohydrates: 12.0, protein: 0.9, calories: 47), category: "Fruits"),
        FoodTemplate(name: "Strawberries", nutritionPer100g: NutritionInfo(carbohydrates: 8.0, protein: 0.7, calories: 32), category: "Fruits"),
        FoodTemplate(name: "Blueberries", nutritionPer100g: NutritionInfo(carbohydrates: 14.0, protein: 0.7, calories: 57), category: "Fruits"),
        FoodTemplate(name: "Grapes", nutritionPer100g: NutritionInfo(carbohydrates: 18.0, protein: 0.7, calories: 69), category: "Fruits"),
        FoodTemplate(name: "Avocado", nutritionPer100g: NutritionInfo(carbohydrates: 9.0, protein: 2.0, calories: 160), category: "Fruits"),
        
        // Dairy
        FoodTemplate(name: "Milk (Whole)", nutritionPer100g: NutritionInfo(carbohydrates: 5.0, protein: 3.3, calories: 61), category: "Dairy"),
        FoodTemplate(name: "Cheese (Cheddar)", nutritionPer100g: NutritionInfo(carbohydrates: 1.3, protein: 25.0, calories: 403), category: "Dairy"),
        FoodTemplate(name: "Greek Yogurt", nutritionPer100g: NutritionInfo(carbohydrates: 3.6, protein: 10.0, calories: 59), category: "Dairy"),
        FoodTemplate(name: "Butter", nutritionPer100g: NutritionInfo(carbohydrates: 0.1, protein: 0.9, calories: 717), category: "Dairy"),
        
        // Nuts & Seeds
        FoodTemplate(name: "Almonds", nutritionPer100g: NutritionInfo(carbohydrates: 22.0, protein: 21.0, calories: 579), category: "Nuts"),
        FoodTemplate(name: "Peanuts", nutritionPer100g: NutritionInfo(carbohydrates: 16.0, protein: 26.0, calories: 567), category: "Nuts"),
        FoodTemplate(name: "Walnuts", nutritionPer100g: NutritionInfo(carbohydrates: 14.0, protein: 15.0, calories: 654), category: "Nuts"),
            FoodTemplate(name: "Peanut Butter", nutritionPer100g: NutritionInfo(carbohydrates: 20.0, protein: 25.0, calories: 588), category: "Nuts"),
        ]
    }
    
    let drinks: [DrinkTemplate] = [
        // Non-Alcoholic
        DrinkTemplate(name: "Water", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 0), category: "Water", isAlcoholic: false),
        DrinkTemplate(name: "Coffee (Black)", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0.1, calories: 1), category: "Coffee", isAlcoholic: false),
        DrinkTemplate(name: "Tea (Unsweetened)", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 1), category: "Tea", isAlcoholic: false),
        DrinkTemplate(name: "Orange Juice", nutritionPer100ml: NutritionInfo(carbohydrates: 10.4, protein: 0.7, calories: 45), category: "Juice", isAlcoholic: false),
        DrinkTemplate(name: "Apple Juice", nutritionPer100ml: NutritionInfo(carbohydrates: 11.3, protein: 0.1, calories: 46), category: "Juice", isAlcoholic: false),
        DrinkTemplate(name: "Milk (Whole)", nutritionPer100ml: NutritionInfo(carbohydrates: 5.0, protein: 3.3, calories: 61), category: "Dairy", isAlcoholic: false),
        DrinkTemplate(name: "Milk (Skim)", nutritionPer100ml: NutritionInfo(carbohydrates: 5.0, protein: 3.4, calories: 34), category: "Dairy", isAlcoholic: false),
        DrinkTemplate(name: "Almond Milk (Unsweetened)", nutritionPer100ml: NutritionInfo(carbohydrates: 0.3, protein: 0.4, calories: 13), category: "Dairy", isAlcoholic: false),
        DrinkTemplate(name: "Coca-Cola", nutritionPer100ml: NutritionInfo(carbohydrates: 10.6, protein: 0, calories: 42), category: "Soda", isAlcoholic: false),
        DrinkTemplate(name: "Sprite", nutritionPer100ml: NutritionInfo(carbohydrates: 10.0, protein: 0, calories: 40), category: "Soda", isAlcoholic: false),
        DrinkTemplate(name: "Protein Shake", nutritionPer100ml: NutritionInfo(carbohydrates: 5.0, protein: 8.0, calories: 70), category: "Protein", isAlcoholic: false),
        
        // Alcoholic
        DrinkTemplate(name: "Beer (Regular)", nutritionPer100ml: NutritionInfo(carbohydrates: 3.6, protein: 0.5, calories: 43), category: "Beer", isAlcoholic: true),
        DrinkTemplate(name: "Beer (Light)", nutritionPer100ml: NutritionInfo(carbohydrates: 2.0, protein: 0.3, calories: 29), category: "Beer", isAlcoholic: true),
        DrinkTemplate(name: "Wine (Red)", nutritionPer100ml: NutritionInfo(carbohydrates: 2.6, protein: 0.1, calories: 85), category: "Wine", isAlcoholic: true),
        DrinkTemplate(name: "Wine (White)", nutritionPer100ml: NutritionInfo(carbohydrates: 2.6, protein: 0.1, calories: 82), category: "Wine", isAlcoholic: true),
        DrinkTemplate(name: "Vodka", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 231), category: "Spirits", isAlcoholic: true),
        DrinkTemplate(name: "Whiskey", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 250), category: "Spirits", isAlcoholic: true),
        DrinkTemplate(name: "Rum", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 231), category: "Spirits", isAlcoholic: true),
        DrinkTemplate(name: "Gin", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 263), category: "Spirits", isAlcoholic: true),
        DrinkTemplate(name: "Tequila", nutritionPer100ml: NutritionInfo(carbohydrates: 0, protein: 0, calories: 231), category: "Spirits", isAlcoholic: true),
        DrinkTemplate(name: "Margarita", nutritionPer100ml: NutritionInfo(carbohydrates: 7.0, protein: 0, calories: 153), category: "Cocktail", isAlcoholic: true),
        DrinkTemplate(name: "Mojito", nutritionPer100ml: NutritionInfo(carbohydrates: 10.0, protein: 0, calories: 143), category: "Cocktail", isAlcoholic: true),
    ]
    
    func searchFoods(_ query: String) -> [FoodTemplate] {
        if query.isEmpty {
            return foods
        }
        return foods.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func searchDrinks(_ query: String) -> [DrinkTemplate] {
        if query.isEmpty {
            return drinks
        }
        return drinks.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
