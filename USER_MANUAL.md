# Nutrition Tracker - User Manual

## Overview

Nutrition Tracker is an iOS app designed to help you track your daily food and drink intake, monitor your macronutrients (carbohydrates and protein), and keep an eye on your calorie consumption.

## Features

- **Track Meals**: Record meals with multiple food items and drinks
- **Nutrition Database**: Built-in database with 50+ common foods and 20+ drinks
- **Smart Search**: Auto-complete suggestions as you type food or drink names
- **Automatic Calculations**: Nutrition values auto-calculate based on weight/volume
- **Daily & Weekly Summaries**: View your nutrition intake over time
- **Visual Charts**: See your calorie trends with interactive charts
- **Persistent Storage**: All data is saved locally on your device

## Getting Started

### Main Interface

The app has two main tabs:

1. **Meals Tab** (fork.knife icon): View and manage your recorded meals
2. **Summary Tab** (chart.bar icon): View daily and weekly nutrition summaries

## Using the App

### Recording a Meal

1. **Open the Meals tab**
2. **Tap the + button** in the top-right corner
3. **Enter a meal name** (e.g., "Breakfast", "Lunch", "Dinner")
4. **Add foods and drinks** to your meal

### Adding Food Items

1. **Tap "Add Food"** in the Foods section
2. **Start typing a food name** - suggestions will appear automatically
3. **Select a food from suggestions** or continue typing your own
4. **Enter the weight in grams**
   - If you selected from suggestions, nutrition values auto-populate for 100g
   - Change the weight and values will recalculate automatically
5. **Review nutrition values**:
   - Carbohydrates (g)
   - Protein (g)
   - Calories (kcal)
6. **Tap "Add Food"** to add to your meal

#### Food Database Categories

The app includes foods in these categories:
- **Protein**: Eggs, chicken, salmon, tuna, beef, pork, turkey, ham, bacon, tofu
- **Vegetables**: Broccoli, spinach, carrots, cauliflower, green beans, asparagus, peppers, tomatoes
- **Carbs**: White rice, brown rice, pasta, bread, oatmeal, quinoa, potatoes
- **Fruits**: Apple, banana, orange, strawberries, blueberries, grapes, avocado
- **Dairy**: Milk, cheese, Greek yogurt, butter
- **Nuts & Seeds**: Almonds, peanuts, walnuts, peanut butter

### Adding Drinks

1. **Tap "Add Drink"** in the Drinks section
2. **Start typing a drink name** - suggestions will appear automatically
3. **Select a drink from suggestions** or continue typing your own
4. **Enter the volume in milliliters (ml)**
   - If you selected from suggestions, nutrition values auto-populate for 100ml
   - Change the volume and values will recalculate automatically
5. **Toggle "Alcoholic"** if applicable (auto-set for alcoholic drinks in database)
6. **Review nutrition values**:
   - Carbohydrates (g)
   - Protein (g)
   - Calories (kcal)
7. **Tap "Add Drink"** to add to your meal

#### Drink Database Categories

The app includes:
- **Non-Alcoholic**: Water, coffee, tea, juices, milk, sodas, protein shakes
- **Alcoholic**: Beer (regular & light), wine (red & white), spirits (vodka, whiskey, rum, gin, tequila), cocktails

Alcoholic drinks are marked with a 🍺 emoji.

### Saving a Meal

1. **Review the Total Nutrition** section at the bottom
2. **Tap "Save Meal"** when done
3. The meal is saved with the current date and time

### Viewing Meals

In the **Meals tab**, you'll see:
- List of all meals, sorted by most recent first
- Meal name and date
- Foods and drinks in each meal
- Total nutrition for each meal (carbs, protein, calories)

**To delete a meal**: Swipe left on any meal and tap Delete

### Viewing Summaries

The **Summary tab** has two views:

#### Daily View

- **Last 7 Days Chart**: Bar chart showing daily calorie intake
- **Daily Breakdown**: Cards for each day showing:
  - Date
  - Total carbohydrates (g)
  - Total protein (g)
  - Total calories
  - Number of meals

#### Weekly View

- **Weekly Trends Chart**: Line chart showing calorie trends over 4 weeks
- **Weekly Breakdown**: Cards for each week showing:
  - Week start date
  - Total carbohydrates (g)
  - Total protein (g)
  - Total calories

Switch between views using the segmented control at the top.

## Tips & Best Practices

### Accurate Tracking

- **Weigh your food**: Use a kitchen scale for accurate measurements
- **Log immediately**: Record meals right after eating for best accuracy
- **Be specific**: Use descriptive meal names to track eating patterns

### Using the Database

- **Standard portions**: Database values are per 100g for foods and per 100ml for drinks
- **Common measurements**:
  - 1 cup of rice (cooked) ≈ 150-200g
  - 1 chicken breast ≈ 150-200g
  - 1 can of soda ≈ 330ml
  - 1 glass of wine ≈ 150ml
  - 1 beer (bottle/can) ≈ 330-355ml

### Custom Foods

If a food isn't in the database:
1. Type the name anyway
2. Manually enter the nutrition values from the product label
3. The app will remember your entry for that meal

## Understanding Your Data

### Macronutrients

- **Carbohydrates**: Primary energy source (4 calories per gram)
- **Protein**: Building blocks for muscles and tissues (4 calories per gram)
- **Fats**: Not currently tracked (9 calories per gram)

### Calorie Tracking

The app tracks total calories, which come from carbohydrates, proteins, and fats. Note that the app's calorie calculations may not account for all fat content, as only carbs and protein are explicitly tracked.

### Daily Goals (Not Built-In)

The app doesn't set goals, but common guidelines:
- **Average adult**: 2000-2500 calories/day
- **Protein**: 0.8-1.0g per kg of body weight
- **Carbohydrates**: 45-65% of total calories

Consult a nutritionist for personalized recommendations.

## Data & Privacy

- **All data is stored locally** on your device
- **No cloud sync**: Data is not transmitted or stored externally
- **Data persistence**: Data is saved using iOS UserDefaults
- **Backup**: Data is included in iOS device backups

## Troubleshooting

### Issue: Can't find a food/drink
**Solution**: Type the full name or a close match. If still not found, enter manually.

### Issue: Wrong nutrition values after selecting from database
**Solution**: Adjust the weight/volume first, then values will recalculate. Or manually edit the values.

### Issue: Meal won't save
**Solution**: Ensure meal has a name and at least one food or drink item.

### Issue: Lost all my data
**Solution**: Check if you restored your device or switched devices. Data is local only - restore from iOS backup if needed.

### Issue: Chart not showing data
**Solution**: You need at least 2 days of data for charts to display properly.

## Support & Feedback

This is a personal nutrition tracking app. For issues or feature requests, contact the app developer.

## Version Information

- **Platform**: iOS (SwiftUI)
- **Minimum iOS**: iOS 16.0 or later
- **Storage**: Local device storage only
- **Languages**: English
