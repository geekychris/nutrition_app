# Adding Camera and Photo Library Permissions

The app needs explicit permissions to access the camera and photo library. Follow these steps in Xcode:

## Method 1: Using Xcode's Info Tab (Easiest)

1. **Open the project in Xcode**
   ```bash
   open NutritionTracker.xcodeproj
   ```

2. **Select the project** (NutritionTracker) in the left sidebar

3. **Select the target** "NutritionTracker" under TARGETS

4. **Go to the "Info" tab**

5. **Add the following keys** by clicking the + button:
   
   **Camera Usage:**
   - Key: `Privacy - Camera Usage Description`
   - Type: String
   - Value: `We need access to your camera to take photos of your meals.`
   
   **Photo Library Usage:**
   - Key: `Privacy - Photo Library Usage Description`
   - Type: String
   - Value: `We need access to your photo library to choose meal photos.`

## Method 2: Using Property List Editor

If you have an Info.plist file:

1. **Find Info.plist** in the NutritionTracker folder

2. **Right-click** and open with "Property List Editor" or source code editor

3. **Add these keys:**
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need access to your camera to take photos of your meals.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photo library to choose meal photos.</string>
   ```

## Method 3: Command Line (Quick Fix)

Run this command from the project directory:

```bash
/usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'We need access to your camera to take photos of your meals.'" NutritionTracker/Info.plist 2>/dev/null || echo "Key already exists or file not found"

/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string 'We need access to your photo library to choose meal photos.'" NutritionTracker/Info.plist 2>/dev/null || echo "Key already exists or file not found"
```

## Verify the Permissions

After adding:

1. **Clean build folder**: Cmd + Shift + K
2. **Rebuild**: Cmd + B
3. **Run on device/simulator**: Cmd + R

The first time you try to take a photo or choose from library, iOS will show a permission dialog with your description.

## Required Keys Summary

| Key | Purpose | Description |
|-----|---------|-------------|
| `NSCameraUsageDescription` | Camera Access | "We need access to your camera to take photos of your meals." |
| `NSPhotoLibraryUsageDescription` | Photo Library | "We need access to your photo library to choose meal photos." |

## Troubleshooting

**App still crashes/freezes?**
1. Delete the app from device/simulator
2. Clean build folder (Cmd + Shift + K)
3. Rebuild and run
4. The permission dialog should appear

**Can't find Info.plist?**
- Modern Xcode projects may not have a visible Info.plist
- Use the Info tab in project settings instead (Method 1)

**Permission dialog doesn't appear?**
- Make sure you deleted and reinstalled the app
- Check device Settings → Privacy → Camera/Photos to manually grant permission
