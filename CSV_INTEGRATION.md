# CSV Data Integration

## Overview
The application has been updated to load food nutrition data from CSV files instead of using hardcoded arrays.

## Changes Made

### 1. Updated NutritionDatabase.swift
- Changed `foods` from a hardcoded array to a dynamically loaded array
- Added `init()` method that calls `loadFoodsFromCSV()`
- Implemented CSV parsing functionality with `parseCSVRow()` method
- Added food categorization logic in `categorizeFood()` method
- Keeps fallback data in case CSV files cannot be loaded

### 2. CSV File Loading
The system loads data from 5 CSV files in the `dataset` directory:
- FOOD-DATA-GROUP1.csv (551 foods)
- FOOD-DATA-GROUP2.csv (319 foods)
- FOOD-DATA-GROUP3.csv (571 foods)
- FOOD-DATA-GROUP4.csv (232 foods)
- FOOD-DATA-GROUP5.csv (722 foods)

**Total: 2,395 food items**

### 3. Path Resolution
The code tries two paths to find the CSV files:
1. **Bundle resources**: For production builds where files are bundled with the app
2. **Project directory**: For development builds using relative path from source file

### 4. Food Categorization
Foods are automatically categorized based on:
- **Name patterns**: Keywords like "chicken", "rice", "apple", etc.
- **Nutritional content**: High protein/low carb = Protein, high carbs = Carbs, etc.
- **Categories**: Protein, Carbs, Fruits, Vegetables, Dairy, Nuts, Other

### 5. CSV Format
The CSV files have the following columns (per 100g):
- Column 2: Food name
- Column 3: Caloric Value (kcal)
- Column 8: Carbohydrates (g)
- Column 10: Protein (g)

## Adding Dataset to Xcode Project

To ensure the CSV files are bundled with the app:

1. Open the Xcode project
2. Right-click on the project navigator
3. Select "Add Files to NutritionTracker..."
4. Navigate to and select the `dataset` folder
5. **Important**: Check "Create folder references" (not "Create groups")
6. Click "Add"

This ensures the dataset folder and all CSV files are included in the app bundle.

## Drinks
The drinks database remains hardcoded as the CSV files primarily contain food data. The original 20+ drink templates are still available.

## Testing
The application successfully:
- ✅ Compiles without errors
- ✅ Loads 2,395 foods from CSV files during development
- ✅ Falls back to hardcoded data if CSV files are not found
- ✅ Maintains backward compatibility with existing functionality
- ✅ Categorizes all foods automatically

## Future Improvements
- Add drinks CSV file support
- Implement caching for faster startup
- Add more detailed nutritional information from CSV columns
- Support for additional CSV columns (vitamins, minerals, etc.)
