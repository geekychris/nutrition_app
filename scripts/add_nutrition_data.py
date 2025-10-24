#!/usr/bin/env python3
"""
Add Nutrition Data Script for Nutrition Tracker
This script helps batch-add nutrition data from CSV files to the database

CSV Format for Foods:
name,carbohydrates,protein,calories,category

CSV Format for Drinks:
name,carbohydrates,protein,calories,category,is_alcoholic

Example usage:
    python3 add_nutrition_data.py foods.csv --type food
    python3 add_nutrition_data.py drinks.csv --type drink
"""

import csv
import sys
import argparse
from pathlib import Path


def generate_food_template(name, carbs, protein, calories, category):
    """Generate Swift code for a FoodTemplate"""
    return f'FoodTemplate(name: "{name}", nutritionPer100g: NutritionInfo(carbohydrates: {carbs}, protein: {protein}, calories: {calories}), category: "{category}"),'


def generate_drink_template(name, carbs, protein, calories, category, is_alcoholic):
    """Generate Swift code for a DrinkTemplate"""
    alcoholic = "true" if is_alcoholic.lower() in ['true', 'yes', '1'] else "false"
    return f'DrinkTemplate(name: "{name}", nutritionPer100ml: NutritionInfo(carbohydrates: {carbs}, protein: {protein}, calories: {calories}), category: "{category}", isAlcoholic: {alcoholic}),'


def process_csv(csv_file, data_type):
    """Process CSV file and generate Swift code"""
    print(f"\nProcessing {csv_file} as {data_type}...")
    print("\n" + "="*60)
    print(f"Add the following to NutritionDatabase.swift:")
    print("="*60 + "\n")
    
    try:
        with open(csv_file, 'r') as f:
            reader = csv.DictReader(f)
            count = 0
            
            for row in reader:
                name = row['name'].strip()
                carbs = float(row['carbohydrates'])
                protein = float(row['protein'])
                calories = float(row['calories'])
                category = row['category'].strip()
                
                if data_type == 'food':
                    print(generate_food_template(name, carbs, protein, calories, category))
                elif data_type == 'drink':
                    is_alcoholic = row.get('is_alcoholic', 'false').strip()
                    print(generate_drink_template(name, carbs, protein, calories, category, is_alcoholic))
                
                count += 1
            
            print("\n" + "="*60)
            print(f"✅ Processed {count} items successfully!")
            print("="*60)
            
    except FileNotFoundError:
        print(f"❌ Error: File '{csv_file}' not found!")
        sys.exit(1)
    except KeyError as e:
        print(f"❌ Error: Missing required column {e}")
        print(f"\nRequired columns for {data_type}:")
        if data_type == 'food':
            print("  - name, carbohydrates, protein, calories, category")
        else:
            print("  - name, carbohydrates, protein, calories, category, is_alcoholic")
        sys.exit(1)
    except ValueError as e:
        print(f"❌ Error: Invalid numeric value - {e}")
        sys.exit(1)


def create_sample_csv(data_type):
    """Create a sample CSV file"""
    if data_type == 'food':
        filename = 'sample_foods.csv'
        content = """name,carbohydrates,protein,calories,category
Shrimp,0.2,24.0,99,Protein
Lamb Chop,0,25.0,294,Protein
Green Peas,14.0,5.4,81,Vegetables
Mushrooms,3.3,3.1,22,Vegetables
Couscous,23.0,3.8,112,Carbs
"""
    else:
        filename = 'sample_drinks.csv'
        content = """name,carbohydrates,protein,calories,category,is_alcoholic
Champagne,1.4,0.2,83,Wine,true
IPA Beer,5.0,0.7,60,Beer,true
Lemonade,12.0,0,48,Juice,false
Coconut Water,3.7,0.7,19,Water,false
Espresso,0,0.1,2,Coffee,false
"""
    
    with open(filename, 'w') as f:
        f.write(content)
    
    print(f"✅ Created sample file: {filename}")
    print(f"\nEdit this file and run:")
    print(f"  python3 add_nutrition_data.py {filename} --type {data_type}")


def main():
    parser = argparse.ArgumentParser(
        description='Add nutrition data to Nutrition Tracker database',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Process a food CSV file
  python3 add_nutrition_data.py foods.csv --type food
  
  # Process a drink CSV file
  python3 add_nutrition_data.py drinks.csv --type drink
  
  # Create sample CSV files
  python3 add_nutrition_data.py --sample food
  python3 add_nutrition_data.py --sample drink

CSV Format:
  Foods:  name, carbohydrates, protein, calories, category
  Drinks: name, carbohydrates, protein, calories, category, is_alcoholic
        """
    )
    
    parser.add_argument('csv_file', nargs='?', help='Path to CSV file')
    parser.add_argument('--type', choices=['food', 'drink'], help='Type of nutrition data')
    parser.add_argument('--sample', choices=['food', 'drink'], help='Create a sample CSV file')
    
    args = parser.parse_args()
    
    if args.sample:
        create_sample_csv(args.sample)
    elif args.csv_file and args.type:
        process_csv(args.csv_file, args.type)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == '__main__':
    main()
