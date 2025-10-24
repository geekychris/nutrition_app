# Nutrition Tracker - Developer Guide

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Data Models](#data-models)
5. [Building the Project](#building-the-project)
6. [Extending the Nutrition Database](#extending-the-nutrition-database)
7. [Deployment](#deployment)
8. [Testing](#testing)
9. [Future Enhancements](#future-enhancements)

## System Overview

Nutrition Tracker is a native iOS application built with SwiftUI that allows users to track their food and drink intake, monitor macronutrients, and visualize their nutritional data over time.

### Key Technologies

- **Framework**: SwiftUI (iOS 16.0+)
- **Language**: Swift 5.9+
- **Charts**: Swift Charts framework
- **Data Persistence**: UserDefaults
- **Architecture**: MVVM (Model-View-ViewModel)

### Core Features

1. Meal creation and management
2. Food and drink tracking with auto-complete
3. Built-in nutrition database
4. Automatic nutrition calculations
5. Daily and weekly summaries
6. Interactive data visualization

## Architecture

### Design Pattern: MVVM

The app follows the Model-View-ViewModel pattern:

```
┌─────────────────┐
│     Views       │  ← SwiftUI Views
└────────┬────────┘
         │ @EnvironmentObject
┌────────▼────────┐
│  DataManager    │  ← ViewModel (ObservableObject)
└────────┬────────┘
         │
┌────────▼────────┐
│     Models      │  ← Data Models (Codable)
└─────────────────┘
```

### Component Overview

#### Models (`Models.swift`)
- **NutritionInfo**: Tracks carbs, protein, and calories
- **FoodItem**: Individual food with weight and nutrition
- **Drink**: Individual drink with volume and nutrition
- **Meal**: Collection of foods and drinks
- **DailySummary**: Aggregated nutrition data per day

#### ViewModel (`DataManager.swift`)
- **DataManager**: Manages app state and data persistence
  - CRUD operations for meals
  - Daily and weekly summary calculations
  - UserDefaults persistence

#### Database (`NutritionDatabase.swift`)
- **NutritionDatabase**: Singleton containing templates
  - 40+ food templates
  - 20+ drink templates
  - Search functionality

#### Views
- **ContentView**: Tab bar container
- **MealsListView**: Displays all meals
- **MealEditorView**: Create/edit meals
- **AddFoodView**: Add food items with search
- **AddDrinkView**: Add drinks with search
- **SummaryView**: Daily and weekly analytics

## Project Structure

```
NutritionTracker/
├── NutritionTracker.xcodeproj/     # Xcode project file
├── NutritionTracker/
│   ├── NutritionTrackerApp.swift   # App entry point
│   ├── ContentView.swift            # Main tab view
│   ├── Models.swift                 # Data models
│   ├── DataManager.swift            # Data management & persistence
│   ├── NutritionDatabase.swift      # Food & drink database
│   ├── MealsListView.swift          # Meals list screen
│   ├── MealEditorView.swift         # Meal creation/edit screen
│   ├── AddFoodView.swift            # Food selection screen
│   ├── AddDrinkView.swift           # Drink selection screen
│   ├── SummaryView.swift            # Analytics screen
│   └── Assets.xcassets/             # Images and icons
├── USER_MANUAL.md                   # User documentation
├── DEVELOPER_GUIDE.md               # This file
└── README.md                        # Project README
```

## Data Models

### NutritionInfo

```swift
struct NutritionInfo: Codable, Hashable {
    var carbohydrates: Double  // in grams
    var protein: Double        // in grams
    var calories: Double       // in kcal
}
```

Represents nutritional data. Supports addition operator for aggregation.

### FoodItem

```swift
struct FoodItem: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var weight: Double         // in grams
    var nutrition: NutritionInfo
    var timestamp: Date
}
```

Represents a food item with a specific weight and its associated nutrition.

### Drink

```swift
struct Drink: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var volume: Double         // in ml
    var nutrition: NutritionInfo
    var isAlcoholic: Bool
    var timestamp: Date
}
```

Represents a drink with a specific volume and its associated nutrition.

### Meal

```swift
struct Meal: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var foods: [FoodItem]
    var drinks: [Drink]
    var timestamp: Date
    
    var totalNutrition: NutritionInfo { ... }
}
```

Container for multiple foods and drinks. Automatically calculates total nutrition.

### Database Templates

```swift
struct FoodTemplate: Identifiable, Hashable {
    var id: UUID
    var name: String
    var nutritionPer100g: NutritionInfo
    var category: String
}

struct DrinkTemplate: Identifiable, Hashable {
    var id: UUID
    var name: String
    var nutritionPer100ml: NutritionInfo
    var category: String
    var isAlcoholic: Bool
}
```

Template definitions for foods and drinks with standard portion sizes.

## Building the Project

### Prerequisites

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: 16.0 or later
- **Apple Developer Account**: Optional (for device deployment)

### Build Steps

1. **Open the project**:
   ```bash
   open NutritionTracker.xcodeproj
   ```

2. **Select a target**:
   - Choose "NutritionTracker" scheme
   - Select an iPhone simulator or connected device

3. **Build and run**:
   - Press `Cmd + R` or click the Play button
   - Or use command line: `xcodebuild -scheme NutritionTracker -destination 'platform=iOS Simulator,name=iPhone 15' build`

### Build Configurations

- **Debug**: Development build with debugging symbols
- **Release**: Optimized build for App Store submission

## Extending the Nutrition Database

The nutrition database is defined in `NutritionDatabase.swift`. Here's how to extend it:

### Adding New Foods

1. **Open** `NutritionDatabase.swift`
2. **Locate** the `foods` array in `NutritionDatabase` class
3. **Add** a new `FoodTemplate`:

```swift
FoodTemplate(
    name: "Chicken Thigh",
    nutritionPer100g: NutritionInfo(
        carbohydrates: 0.0,
        protein: 18.0,
        calories: 209
    ),
    category: "Protein"
)
```

### Adding New Drinks

1. **Open** `NutritionDatabase.swift`
2. **Locate** the `drinks` array in `NutritionDatabase` class
3. **Add** a new `DrinkTemplate`:

```swift
DrinkTemplate(
    name: "Green Tea",
    nutritionPer100ml: NutritionInfo(
        carbohydrates: 0.0,
        protein: 0.0,
        calories: 1
    ),
    category: "Tea",
    isAlcoholic: false
)
```

### Finding Nutrition Data

Sources for accurate nutrition data:

1. **USDA FoodData Central**: https://fdc.nal.usda.gov/
2. **Nutritionix**: https://www.nutritionix.com/
3. **Product labels**: For branded items
4. **MyFitnessPal database**: Community-verified data

### Data Format Guidelines

- **Carbohydrates**: Total carbs in grams per 100g/100ml
- **Protein**: Protein in grams per 100g/100ml
- **Calories**: Energy in kilocalories (kcal) per 100g/100ml
- **Categories**: Use consistent naming (see existing categories)

### Categories

#### Food Categories
- Protein
- Vegetables
- Carbs
- Fruits
- Dairy
- Nuts
- Legumes (suggested)
- Snacks (suggested)

#### Drink Categories
- Water
- Coffee
- Tea
- Juice
- Dairy
- Soda
- Protein
- Beer
- Wine
- Spirits
- Cocktail

### Automated Database Scripts

See the `scripts/` directory for helper scripts to batch-add nutrition data from CSV files.

## Deployment

### Option 1: TestFlight (Recommended)

TestFlight allows you to distribute your app to testers without going through the full App Store review process.

#### Prerequisites
- Apple Developer Program membership ($99/year)
- Xcode with your developer account signed in

#### Steps

1. **Archive the app**:
   ```bash
   xcodebuild -scheme NutritionTracker \
     -archivePath ./build/NutritionTracker.xcarchive \
     archive
   ```

2. **Upload to App Store Connect**:
   - Open Xcode → Window → Organizer
   - Select the archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow the prompts

3. **Configure TestFlight**:
   - Log in to App Store Connect
   - Select your app
   - Go to TestFlight tab
   - Add internal or external testers
   - Share the TestFlight link or invite via email

4. **Testers install**:
   - Testers download TestFlight app from App Store
   - Accept your invitation
   - Install Nutrition Tracker from TestFlight

**Note**: Use the provided script `scripts/archive_and_export.sh` to automate archiving.

### Option 2: Ad Hoc Distribution

For distributing to a small number of devices (up to 100 devices/year).

#### Prerequisites
- Apple Developer Program membership
- Device UDIDs registered in developer portal

#### Steps

1. **Register devices**:
   - Go to Apple Developer Portal → Certificates, Identifiers & Profiles
   - Register device UDIDs

2. **Create Ad Hoc provisioning profile**:
   - Create profile with registered devices
   - Download and install in Xcode

3. **Archive and export**:
   ```bash
   ./scripts/export_adhoc.sh
   ```

4. **Distribute IPA**:
   - Share the `.ipa` file
   - Users install via Finder (Mac) or iTunes (Windows)

### Option 3: Development Build (Quick Testing)

For quick testing on your own device.

#### Steps

1. **Connect your device**
2. **Select device in Xcode**
3. **Build and run** (`Cmd + R`)
4. **Trust developer**:
   - Settings → General → VPN & Device Management
   - Trust your developer certificate

**Note**: Development builds expire after 7 days (free account) or 1 year (paid account).

### Option 4: App Store Distribution

For public release on the App Store.

#### Steps

1. **Prepare App Store Connect**:
   - Create app listing
   - Add screenshots, description, keywords
   - Set pricing and availability

2. **Archive and submit**:
   - Follow TestFlight steps above
   - After upload, click "Submit for Review"

3. **App Review**:
   - Apple reviews your app (1-3 days typically)
   - Address any feedback

4. **Release**:
   - Once approved, release immediately or schedule

**Note**: First-time submission requires more setup (privacy policy, app icons, etc.)

### Deployment Scripts

The following helper scripts are provided in the `scripts/` directory:

- `archive_and_export.sh`: Archive the app for distribution
- `export_ipa.sh`: Export IPA file for ad hoc distribution
- `increment_build.sh`: Automatically increment build number
- `install_device.sh`: Install directly to connected iOS device

## Testing

### Manual Testing

1. **Unit Tests**: Currently not implemented
2. **UI Tests**: Currently not implemented
3. **Manual Testing Checklist**:
   - [ ] Add meal with multiple foods
   - [ ] Add meal with drinks
   - [ ] Search for foods in database
   - [ ] Custom food entry
   - [ ] Delete meals
   - [ ] View daily summaries
   - [ ] View weekly summaries
   - [ ] Verify data persistence after app restart

### Automated Testing (Future)

Create unit tests in `NutritionTrackerTests/`:

```swift
import XCTest
@testable import NutritionTracker

class NutritionInfoTests: XCTestCase {
    func testAddition() {
        let info1 = NutritionInfo(carbohydrates: 10, protein: 5, calories: 100)
        let info2 = NutritionInfo(carbohydrates: 15, protein: 10, calories: 150)
        let sum = info1 + info2
        
        XCTAssertEqual(sum.carbohydrates, 25)
        XCTAssertEqual(sum.protein, 15)
        XCTAssertEqual(sum.calories, 250)
    }
}
```

## Future Enhancements

### Suggested Features

1. **Fat Tracking**: Add fat to NutritionInfo model
2. **Micronutrients**: Vitamins, minerals, fiber
3. **Barcode Scanning**: Use Vision framework
4. **Photo Logging**: Associate photos with meals
5. **Export Data**: CSV/JSON export functionality
6. **Goals & Targets**: Daily nutrition goals
7. **Meal Templates**: Save and reuse common meals
8. **Water Intake**: Dedicated water tracking
9. **Cloud Sync**: iCloud or custom backend
10. **Widgets**: iOS home screen widgets
11. **Apple Health Integration**: Sync with HealthKit
12. **Multiple Users**: Profile support
13. **Search History**: Recent food searches
14. **Favorites**: Quick-add favorite foods
15. **Meal Photos**: Camera integration

### Technical Improvements

1. **Core Data**: Replace UserDefaults for better performance
2. **Unit Tests**: Comprehensive test coverage
3. **UI Tests**: Automated UI testing
4. **Localization**: Multi-language support
5. **Accessibility**: VoiceOver improvements
6. **Error Handling**: Better error messages
7. **Logging**: Analytics and crash reporting
8. **Performance**: Optimize for large datasets

## API Documentation

### DataManager Methods

```swift
class DataManager: ObservableObject {
    // Add a new meal
    func addMeal(_ meal: Meal)
    
    // Delete an existing meal
    func deleteMeal(_ meal: Meal)
    
    // Update an existing meal
    func updateMeal(_ meal: Meal)
    
    // Get daily summaries grouped by date
    func getDailySummaries() -> [DailySummary]
    
    // Get weekly summaries for specified number of weeks
    func getWeeklySummaries(weeks: Int = 4) -> [(weekStart: Date, nutrition: NutritionInfo)]
}
```

### NutritionDatabase Methods

```swift
class NutritionDatabase {
    static let shared: NutritionDatabase
    
    // Search foods by name (case-insensitive)
    func searchFoods(_ query: String) -> [FoodTemplate]
    
    // Search drinks by name (case-insensitive)
    func searchDrinks(_ query: String) -> [DrinkTemplate]
}
```

## Troubleshooting Build Issues

### Common Issues

**Issue**: "No matching provisioning profiles found"
- **Solution**: Sign in with Apple ID in Xcode Preferences → Accounts

**Issue**: "iOS deployment target too low"
- **Solution**: Set to iOS 16.0+ in project settings

**Issue**: "Command PhaseScriptExecution failed"
- **Solution**: Clean build folder (`Cmd + Shift + K`) and rebuild

**Issue**: "SwiftUI preview not working"
- **Solution**: Ensure simulator is iOS 16.0+, restart Xcode

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code consistency
- Add comments for complex logic
- Keep views small and focused

## License

This project is provided as-is for personal use. Modify as needed for your requirements.

## Contact

For questions or support, contact the project maintainer.
