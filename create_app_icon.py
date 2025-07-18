#!/usr/bin/env python3
"""
Faith Klinik Ministries - App Icon Generator
Creates app icons for iOS and Android
"""

import os
from PIL import Image, ImageDraw, ImageFont

# Create icons directory
os.makedirs("app_icons", exist_ok=True)

# Faith Klinik color scheme
COLORS = {
    'primary': '#4a046a',        # Deep purple
    'secondary': '#094880',      # Deep blue
    'accent': '#85e1f7',         # Light blue
    'white': '#ffffff',
    'light_purple': '#8b5cf6',
}

def create_gradient_circle(size, color1, color2):
    """Create a circular gradient background"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Create gradient
    center = size // 2
    radius = center - 20
    
    # Draw gradient circles
    for i in range(radius, 0, -1):
        factor = i / radius
        r = int(int(color1[1:3], 16) * factor + int(color2[1:3], 16) * (1 - factor))
        g = int(int(color1[3:5], 16) * factor + int(color2[3:5], 16) * (1 - factor))
        b = int(int(color1[5:7], 16) * factor + int(color2[5:7], 16) * (1 - factor))
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, 255))
    
    return image

def create_app_icon(size):
    """Create app icon for given size"""
    # Create gradient background
    icon = create_gradient_circle(size, COLORS['primary'], COLORS['light_purple'])
    draw = ImageDraw.Draw(icon)
    
    # Calculate sizes based on icon size
    heart_size = size // 3
    text_size = size // 8
    
    try:
        # Try to load system font
        if size >= 40:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", max(text_size, 20))
            large_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", max(size // 6, 30))
        else:
            font = ImageFont.load_default()
            large_font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
        large_font = ImageFont.load_default()
    
    # Draw heart shape (simplified)
    center = size // 2
    heart_y = center - heart_size // 4
    
    # Draw heart using circles and triangle
    heart_radius = heart_size // 4
    left_circle = (center - heart_radius // 2, heart_y)
    right_circle = (center + heart_radius // 2, heart_y)
    
    # Draw heart shape
    draw.ellipse([left_circle[0] - heart_radius, left_circle[1] - heart_radius,
                  left_circle[0] + heart_radius, left_circle[1] + heart_radius], 
                 fill=COLORS['white'])
    draw.ellipse([right_circle[0] - heart_radius, right_circle[1] - heart_radius,
                  right_circle[0] + heart_radius, right_circle[1] + heart_radius], 
                 fill=COLORS['white'])
    
    # Draw heart bottom triangle
    triangle_top = heart_y + heart_radius // 2
    triangle_bottom = heart_y + heart_size
    draw.polygon([
        (center, triangle_bottom),
        (center - heart_radius, triangle_top),
        (center + heart_radius, triangle_top)
    ], fill=COLORS['white'])
    
    # Add text
    text_y = center + heart_size // 2 + 20
    draw.text((center, text_y), "FK", font=large_font, fill=COLORS['white'], anchor="mm")
    
    # Add small cross
    cross_size = size // 12
    cross_x = center + heart_size // 2
    cross_y = center - heart_size // 2
    
    # Vertical line
    draw.line([cross_x, cross_y - cross_size, cross_x, cross_y + cross_size], 
              fill=COLORS['white'], width=3)
    # Horizontal line
    draw.line([cross_x - cross_size, cross_y, cross_x + cross_size, cross_y], 
              fill=COLORS['white'], width=3)
    
    return icon

def create_all_icons():
    """Create all required app icons"""
    
    # iOS icon sizes
    ios_sizes = [
        (1024, "AppStore"),      # App Store
        (180, "iPhone@3x"),      # iPhone 6 Plus, 6s Plus, 7 Plus, 8 Plus
        (120, "iPhone@2x"),      # iPhone 6, 6s, 7, 8
        (87, "iPhone@3x_Settings"),  # iPhone 6 Plus, 6s Plus, 7 Plus, 8 Plus Settings
        (80, "iPhone@2x_Spotlight"), # iPhone 6, 6s, 7, 8 Spotlight
        (76, "iPad"),            # iPad
        (152, "iPad@2x"),        # iPad Retina
        (60, "iPhone"),          # iPhone
        (58, "iPhone@2x_Settings"), # iPhone 6, 6s, 7, 8 Settings
        (40, "iPhone@2x_Spotlight_Settings"), # iPhone 6, 6s, 7, 8 Spotlight/Settings
        (29, "iPhone_Settings"), # iPhone Settings
        (20, "iPhone_Notification"), # iPhone Notification
        (167, "iPad_Pro"),       # iPad Pro
    ]
    
    # Android icon sizes
    android_sizes = [
        (512, "PlayStore"),      # Google Play Store
        (192, "xxxhdpi"),        # xxxhdpi
        (144, "xxhdpi"),         # xxhdpi
        (96, "xhdpi"),           # xhdpi
        (72, "hdpi"),            # hdpi
        (48, "mdpi"),            # mdpi
        (36, "ldpi"),            # ldpi
    ]
    
    print("Creating iOS app icons...")
    ios_dir = "app_icons/iOS"
    os.makedirs(ios_dir, exist_ok=True)
    
    for size, name in ios_sizes:
        print(f"  Creating {name} ({size}x{size})...")
        icon = create_app_icon(size)
        icon.save(f"{ios_dir}/Icon-{name}-{size}x{size}.png")
    
    print("\nCreating Android app icons...")
    android_dir = "app_icons/Android"
    os.makedirs(android_dir, exist_ok=True)
    
    for size, name in android_sizes:
        print(f"  Creating {name} ({size}x{size})...")
        icon = create_app_icon(size)
        icon.save(f"{android_dir}/Icon-{name}-{size}x{size}.png")
    
    # Create adaptive icon for Android
    print("\nCreating Android adaptive icon...")
    adaptive_dir = "app_icons/Android/Adaptive"
    os.makedirs(adaptive_dir, exist_ok=True)
    
    # Create foreground (larger icon for adaptive)
    foreground = create_app_icon(432)  # 432x432 for adaptive icon
    foreground.save(f"{adaptive_dir}/ic_launcher_foreground.png")
    
    # Create background (solid color)
    background = Image.new('RGBA', (432, 432), (*[int(COLORS['primary'][i:i+2], 16) for i in (1, 3, 5)], 255))
    background.save(f"{adaptive_dir}/ic_launcher_background.png")
    
    print("\n✅ All app icons created successfully!")
    print(f"📁 Location: {os.path.abspath('app_icons')}")
    print("\n📱 Icon sizes created:")
    print("iOS: 13 sizes (including App Store 1024x1024)")
    print("Android: 7 sizes (including Play Store 512x512)")
    print("Android Adaptive: Foreground + Background")

if __name__ == "__main__":
    create_all_icons()