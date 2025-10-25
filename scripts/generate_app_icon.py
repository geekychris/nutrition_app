#!/usr/bin/env python3
"""
Generate App Icon for Nutrition Tracker
Creates a 1024x1024 app icon with a nutrition theme
"""

import os
from PIL import Image, ImageDraw, ImageFont

def create_app_icon(output_path, size=1024):
    """Create a nutrition-themed app icon"""
    
    # Create a new image with gradient background
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (green to lighter green)
    for y in range(size):
        # Gradient from vibrant green to lighter green
        ratio = y / size
        r = int(76 + (144 - 76) * ratio)
        g = int(175 + (238 - 175) * ratio)
        b = int(80 + (144 - 80) * ratio)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b))
    
    # Draw a circular background for the icon
    circle_size = int(size * 0.75)
    circle_offset = (size - circle_size) // 2
    draw.ellipse(
        [(circle_offset, circle_offset), 
         (circle_offset + circle_size, circle_offset + circle_size)],
        fill=(255, 255, 255, 255)
    )
    
    # Draw apple icon (nutrition symbol)
    apple_center_x = size // 2
    apple_center_y = int(size * 0.52)
    apple_width = int(size * 0.35)
    apple_height = int(size * 0.4)
    
    # Apple body (two overlapping circles)
    left_circle_x = apple_center_x - int(apple_width * 0.22)
    right_circle_x = apple_center_x + int(apple_width * 0.22)
    circle_y = apple_center_y
    circle_radius = int(apple_width * 0.4)
    
    # Draw apple (red color)
    apple_color = (220, 53, 69)  # Red
    
    # Left circle
    draw.ellipse(
        [(left_circle_x - circle_radius, circle_y - circle_radius),
         (left_circle_x + circle_radius, circle_y + circle_radius)],
        fill=apple_color
    )
    
    # Right circle
    draw.ellipse(
        [(right_circle_x - circle_radius, circle_y - circle_radius),
         (right_circle_x + circle_radius, circle_y + circle_radius)],
        fill=apple_color
    )
    
    # Top indent (to make it look more like an apple)
    indent_y = circle_y - int(circle_radius * 0.85)
    indent_radius = int(circle_radius * 0.25)
    draw.ellipse(
        [(apple_center_x - indent_radius, indent_y - indent_radius),
         (apple_center_x + indent_radius, indent_y + indent_radius)],
        fill=(255, 255, 255)
    )
    
    # Draw stem
    stem_width = int(size * 0.018)
    stem_height = int(size * 0.08)
    stem_x = apple_center_x - stem_width // 2
    stem_y = circle_y - int(circle_radius * 0.95) - stem_height
    draw.rectangle(
        [(stem_x, stem_y),
         (stem_x + stem_width, stem_y + stem_height)],
        fill=(101, 67, 33)  # Brown
    )
    
    # Draw leaf
    leaf_color = (76, 175, 80)  # Green
    leaf_points = [
        (stem_x + stem_width, stem_y + int(stem_height * 0.3)),
        (stem_x + stem_width + int(size * 0.05), stem_y + int(stem_height * 0.15)),
        (stem_x + stem_width + int(size * 0.08), stem_y + int(stem_height * 0.5)),
        (stem_x + stem_width + int(size * 0.04), stem_y + int(stem_height * 0.6)),
    ]
    draw.polygon(leaf_points, fill=leaf_color)
    
    # Add subtle shine effect on apple
    shine_radius = int(circle_radius * 0.3)
    shine_x = left_circle_x - int(circle_radius * 0.3)
    shine_y = circle_y - int(circle_radius * 0.4)
    
    # Create semi-transparent white overlay for shine
    shine_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    shine_draw = ImageDraw.Draw(shine_overlay)
    shine_draw.ellipse(
        [(shine_x - shine_radius, shine_y - shine_radius),
         (shine_x + shine_radius, shine_y + shine_radius)],
        fill=(255, 255, 255, 100)
    )
    
    # Convert base image to RGBA and composite
    img = img.convert('RGBA')
    img = Image.alpha_composite(img, shine_overlay)
    
    # Convert back to RGB for saving as PNG/JPG
    final_img = Image.new('RGB', img.size, (255, 255, 255))
    final_img.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
    
    # Save
    final_img.save(output_path, 'PNG', quality=100)
    print(f"✅ App icon created: {output_path}")
    print(f"   Size: {size}x{size}px")

def main():
    """Main function"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    icon_dir = os.path.join(
        project_dir,
        'NutritionTracker',
        'Assets.xcassets',
        'AppIcon.appiconset'
    )
    
    output_path = os.path.join(icon_dir, 'icon_1024.png')
    
    print("Generating Nutrition Tracker app icon...")
    print(f"Output directory: {icon_dir}")
    
    # Create the icon
    create_app_icon(output_path, size=1024)
    
    print("\nNext steps:")
    print("1. Open Xcode")
    print("2. Select Assets.xcassets in the project navigator")
    print("3. Select AppIcon")
    print("4. Drag icon_1024.png to the 1024x1024 slot")
    print("5. Build and run!")

if __name__ == '__main__':
    main()
