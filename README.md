# Nutrition Tracker

A native iOS app for tracking food and drink intake, monitoring macronutrients, and visualizing nutritional data over time.

![Platform](https://img.shields.io/badge/platform-iOS%2016.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green)

## Features

- 📊 **Track Meals**: Record meals with multiple food items and drinks
- 🗄️ **Nutrition Database**: 50+ foods and 20+ drinks with nutritional data
- 🔍 **Smart Search**: Auto-complete suggestions as you type
- 📈 **Analytics**: Daily and weekly summaries with interactive charts
- 💾 **Persistent Storage**: All data saved locally on device
- 🎯 **Auto-Calculations**: Nutrition values calculated automatically based on portions

## Screenshots

*Add screenshots here when available*

## Quick Start

### For Users

See [USER_MANUAL.md](USER_MANUAL.md) for complete instructions on using the app.

### For Developers

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for system architecture, building, and deployment instructions.

## Installation Options

### Option 1: Build from Source (Quick Test)

1. **Clone or download** this repository
2. **Open** `NutritionTracker.xcodeproj` in Xcode
3. **Connect** your iPhone/iPad via USB
4. **Select** your device in Xcode
5. **Press** `Cmd + R` to build and run
6. **Trust** the developer certificate on your device (Settings → General → VPN & Device Management)

**Note**: Development builds expire after 7 days (free Apple ID) or 1 year (paid account).

### Option 2: TestFlight (Recommended for Beta Testing)

TestFlight allows easy distribution to multiple testers.

**Prerequisites:**
- Apple Developer Program membership ($99/year)

**Steps:**
1. Run the archive script:
   ```bash
   ./scripts/archive_and_export.sh
   ```
2. Open Xcode → Window → Organizer
3. Select the archive and click "Distribute App"
4. Choose "App Store Connect" and follow prompts
5. Configure TestFlight in App Store Connect
6. Share the TestFlight link with testers

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md#deployment) for detailed instructions.

### Option 3: Ad Hoc Distribution

For distributing to specific devices without TestFlight.

**Prerequisites:**
- Apple Developer Program membership
- Registered device UDIDs

**Steps:**
1. Register devices in Apple Developer Portal
2. Run:
   ```bash
   ./scripts/archive_and_export.sh
   ./scripts/export_adhoc.sh
   ```
3. Share the `.ipa` file from `build/adhoc/`
4. Users install via Finder (Mac) or Apple Configurator

## Project Structure

```
NutritionTracker/
├── NutritionTracker/           # Main app source code
│   ├── Models.swift            # Data models
│   ├── DataManager.swift       # Data persistence
│   ├── NutritionDatabase.swift # Food & drink database
│   └── Views/                  # SwiftUI views
├── scripts/                    # Helper scripts
│   ├── archive_and_export.sh  # Archive for distribution
│   ├── export_adhoc.sh        # Export IPA file
│   ├── increment_build.sh     # Increment build number
│   ├── install_device.sh      # Install to connected device
│   └── add_nutrition_data.py  # Add nutrition data from CSV
├── USER_MANUAL.md             # User documentation
├── DEVELOPER_GUIDE.md         # Developer documentation
└── README.md                  # This file
```

## Helper Scripts

### Build & Deploy

```bash
# Archive for distribution
./scripts/archive_and_export.sh

# Export Ad Hoc IPA
./scripts/export_adhoc.sh

# Install to connected device
./scripts/install_device.sh

# Increment build number
./scripts/increment_build.sh
```

### Extend Nutrition Database

```bash
# Create sample CSV
python3 scripts/add_nutrition_data.py --sample food

# Process CSV and generate Swift code
python3 scripts/add_nutrition_data.py foods.csv --type food
```

## Technology Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (iOS 16.0+)
- **Charts**: Swift Charts
- **Persistence**: UserDefaults
- **Architecture**: MVVM

## Requirements

- **Xcode**: 15.0 or later
- **macOS**: 13.0 (Ventura) or later
- **iOS Deployment**: 16.0 or later
- **Apple Developer Account**: Optional (required for device deployment beyond 7 days)

## Database

The app includes a built-in nutrition database with:

### Foods (40+ items)
- **Protein**: Eggs, chicken, salmon, beef, etc.
- **Vegetables**: Broccoli, spinach, carrots, etc.
- **Carbs**: Rice, pasta, bread, potatoes, etc.
- **Fruits**: Apple, banana, berries, etc.
- **Dairy**: Milk, cheese, yogurt
- **Nuts**: Almonds, peanuts, walnuts

### Drinks (20+ items)
- **Non-Alcoholic**: Water, coffee, tea, juices, sodas
- **Alcoholic**: Beer, wine, spirits, cocktails

All values are per 100g (foods) or 100ml (drinks).

## Extending the Database

### Manual Method

Edit `NutritionDatabase.swift` and add entries:

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

### Batch Method (CSV)

1. Create a CSV file with nutrition data
2. Run the helper script:
   ```bash
   python3 scripts/add_nutrition_data.py foods.csv --type food
   ```
3. Copy the generated Swift code into `NutritionDatabase.swift`

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md#extending-the-nutrition-database) for details.

## Data Sources

For accurate nutrition data:
- [USDA FoodData Central](https://fdc.nal.usda.gov/)
- [Nutritionix](https://www.nutritionix.com/)
- Product nutrition labels

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Future Enhancements

- [ ] Fat tracking
- [ ] Micronutrients (vitamins, minerals)
- [ ] Barcode scanning
- [ ] Photo logging
- [ ] Daily nutrition goals
- [ ] iCloud sync
- [ ] Apple Health integration
- [ ] Home screen widgets

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md#future-enhancements) for full list.

## Known Issues

- Charts require at least 2 data points to display
- Weekly view shows last 4 weeks only
- No data export functionality yet
- Fat is not currently tracked

## Privacy

- All data stored locally on device
- No network connections
- No data collection or analytics
- No third-party services

## License

This project is provided as-is for personal use.

## Support

For issues or questions:
- See [USER_MANUAL.md](USER_MANUAL.md) for usage help
- See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for technical details
- Contact the project maintainer

## Acknowledgments

Nutrition data sourced from USDA FoodData Central and other public databases.

---

**Made with SwiftUI** 🧡
