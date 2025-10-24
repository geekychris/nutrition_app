# Deployment Scripts - Quick Reference

This directory contains helper scripts for building, deploying, and extending the Nutrition Tracker app.

## Scripts Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `archive_and_export.sh` | Archive app for distribution | Before uploading to App Store/TestFlight |
| `export_adhoc.sh` | Export IPA for ad hoc distribution | Sharing with specific devices |
| `install_device.sh` | Build and install to connected device | Quick testing on your device |
| `increment_build.sh` | Increment build number | Before each new release |
| `add_nutrition_data.py` | Add nutrition data from CSV | Extending the food/drink database |

## Usage

### 1. Archive for Distribution

Creates an archive for TestFlight or App Store submission.

```bash
./scripts/archive_and_export.sh
```

**Output**: `build/NutritionTracker.xcarchive`

**Next Steps**:
1. Open Xcode → Window → Organizer
2. Select the archive
3. Click "Distribute App"
4. Choose distribution method

### 2. Export Ad Hoc IPA

Exports an IPA file for installing on specific devices (requires registered UDIDs).

```bash
# First, create an archive
./scripts/archive_and_export.sh

# Then export the IPA
./scripts/export_adhoc.sh
```

**Prerequisites**:
- Apple Developer Program membership
- Devices registered in Apple Developer Portal
- Update YOUR_TEAM_ID in the script

**Output**: `build/adhoc/NutritionTracker.ipa`

**Distribution**:
- Share IPA file with testers
- Install via Finder (Mac) or Apple Configurator

### 3. Install to Connected Device

Quick build and install to a USB-connected iPhone/iPad.

```bash
./scripts/install_device.sh
```

**Prerequisites**:
- Device connected via USB
- Device trusted (Settings → General → Device Management)
- Developer Mode enabled (Settings → Privacy & Security → Developer Mode)

**Note**: Development builds expire:
- 7 days (free Apple ID)
- 1 year (paid Apple Developer account)

### 4. Increment Build Number

Automatically increment the app's build number before a new release.

```bash
./scripts/increment_build.sh
```

**When to use**:
- Before archiving for a new TestFlight build
- Before submitting to App Store
- When resubmitting after rejection

**Tip**: Commit the change to version control after incrementing.

### 5. Add Nutrition Data

Generate Swift code from CSV files to extend the nutrition database.

#### Create Sample CSV

```bash
# For foods
python3 scripts/add_nutrition_data.py --sample food

# For drinks
python3 scripts/add_nutrition_data.py --sample drink
```

This creates `sample_foods.csv` or `sample_drinks.csv` with example data.

#### Process CSV File

```bash
# For foods
python3 scripts/add_nutrition_data.py foods.csv --type food

# For drinks
python3 scripts/add_nutrition_data.py drinks.csv --type drink
```

**Output**: Swift code printed to console

**Next Steps**:
1. Copy the generated Swift code
2. Open `NutritionDatabase.swift`
3. Paste into the appropriate array (`foods` or `drinks`)
4. Build and test

#### CSV Format

**Foods** (foods.csv):
```csv
name,carbohydrates,protein,calories,category
Chicken Thigh,0.0,18.0,209,Protein
Broccoli,7.0,2.8,34,Vegetables
```

**Drinks** (drinks.csv):
```csv
name,carbohydrates,protein,calories,category,is_alcoholic
Green Tea,0.0,0.0,1,Tea,false
IPA Beer,5.0,0.7,60,Beer,true
```

## Common Workflows

### First-Time Device Testing

```bash
# Connect your device via USB
./scripts/install_device.sh
```

### Preparing for TestFlight

```bash
# Increment build number
./scripts/increment_build.sh

# Archive the app
./scripts/archive_and_export.sh

# Then use Xcode Organizer to upload
```

### Distributing to Beta Testers (Ad Hoc)

```bash
# Register device UDIDs in Apple Developer Portal first
# Edit export_adhoc.sh to set your Team ID

# Archive
./scripts/archive_and_export.sh

# Export IPA
./scripts/export_adhoc.sh

# Share build/adhoc/NutritionTracker.ipa with testers
```

### Adding New Foods

```bash
# Create a CSV file with nutrition data
cat > new_foods.csv << EOF
name,carbohydrates,protein,calories,category
Shrimp,0.2,24.0,99,Protein
Couscous,23.0,3.8,112,Carbs
EOF

# Generate Swift code
python3 scripts/add_nutrition_data.py new_foods.csv --type food

# Copy output and paste into NutritionDatabase.swift
```

## Troubleshooting

### Archive Script Fails

**Issue**: Code signing errors

**Solution**:
1. Open Xcode → Preferences → Accounts
2. Sign in with your Apple ID
3. Download signing certificates
4. Try again

### Export Ad Hoc Fails

**Issue**: "No matching provisioning profiles"

**Solution**:
1. Go to Apple Developer Portal
2. Register device UDIDs
3. Create/update ad hoc provisioning profile
4. Download and install in Xcode

### Install Device Fails

**Issue**: "Device not found"

**Solution**:
1. Connect device via USB
2. Unlock device
3. Trust this computer (prompt on device)
4. Enable Developer Mode: Settings → Privacy & Security → Developer Mode

**Issue**: "Code signing failed"

**Solution**:
1. Open project in Xcode
2. Select project → Signing & Capabilities
3. Select your team
4. Let Xcode manage signing automatically

### Python Script Errors

**Issue**: "Missing required column"

**Solution**: Check your CSV has all required columns:
- Foods: `name`, `carbohydrates`, `protein`, `calories`, `category`
- Drinks: `name`, `carbohydrates`, `protein`, `calories`, `category`, `is_alcoholic`

**Issue**: "Invalid numeric value"

**Solution**: Ensure numeric values don't have text (except column headers)

## Tips

### Automation

Create a deployment script combining multiple steps:

```bash
#!/bin/bash
# deploy.sh
./scripts/increment_build.sh
./scripts/archive_and_export.sh
echo "✅ Ready for upload! Open Xcode Organizer."
```

### Version Control

Always commit changes after:
- Incrementing build number
- Adding nutrition data
- Modifying scripts

### Data Sources

For nutrition data:
- **USDA FoodData Central**: https://fdc.nal.usda.gov/
- **Nutritionix API**: https://www.nutritionix.com/business/api
- **Open Food Facts**: https://world.openfoodfacts.org/

### Batch Processing

To add many items:
1. Create spreadsheet with nutrition data
2. Export as CSV
3. Process with Python script
4. Paste all at once into NutritionDatabase.swift

## Requirements

- **macOS**: 13.0+
- **Xcode**: 15.0+
- **Python**: 3.6+ (for CSV script)
- **Bash**: Any recent version

## Support

For issues with scripts:
1. Check script has execute permissions: `chmod +x scripts/*.sh`
2. Verify you're in the project root directory
3. Check Xcode command line tools: `xcode-select --install`
4. See [DEVELOPER_GUIDE.md](../DEVELOPER_GUIDE.md) for more help

## Contributing

Improvements to scripts are welcome! Please:
1. Test thoroughly before submitting
2. Update this README with any changes
3. Keep scripts POSIX-compliant where possible
4. Add error handling for common failures
