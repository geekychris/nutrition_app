# How to Add Dataset Folder to Xcode Project

## Important: For Production Builds

The dataset folder needs to be added to the Xcode project as a **folder reference** so the CSV files are included in the app bundle.

## Steps:

1. **Open Xcode**
   ```bash
   open NutritionTracker.xcodeproj
   ```

2. **In Xcode Project Navigator (left sidebar):**
   - Right-click on the "NutritionTracker" folder (the yellow folder icon)
   - Select **"Add Files to NutritionTracker..."**

3. **In the file picker dialog:**
   - Navigate to the `dataset` folder in your project directory
   - Select the `dataset` folder
   - **IMPORTANT**: At the bottom of the dialog, select **"Create folder references"** 
     (The folder should appear blue in the project navigator, not yellow)
   - Make sure "Add to targets: NutritionTracker" is checked
   - Click **"Add"**

4. **Verify:**
   - The `dataset` folder should now appear in the project navigator as a **blue folder**
   - Blue = folder reference (files will be in the bundle)
   - Yellow = group (files won't be in the bundle unless added individually)

5. **Build and Run:**
   - Build the project (Cmd+B)
   - Run on simulator or device
   - You should see a console message: "Successfully loaded 2395 foods from CSV files"

## Alternative: Command Line Approach

If you prefer not to use Xcode's GUI, you can run this Ruby script to modify the project file:

```bash
# This would require writing a script to modify the .pbxproj file
# But the GUI method above is simpler and safer
```

## Verification

After adding the dataset folder, the app will:
- Load all 2,395 food items from the CSV files
- Display them in the food search when adding meals
- Automatically categorize foods based on their nutritional content

## Note for Development

During development (running from Xcode), the code automatically finds the CSV files using relative paths, even if they're not in the bundle. This is why the app works without adding the files to Xcode.

However, for **production builds** (TestFlight, App Store), the CSV files **must** be added to the Xcode project as described above.
