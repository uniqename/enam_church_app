#!/usr/bin/env python3
"""
Faith Klinik Ministries - App Store Screenshots Generator
Creates realistic app screenshots for Apple App Store and Google Play Store
"""

import os
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime

# Create screenshots directory
os.makedirs("screenshots", exist_ok=True)

# Faith Klinik color scheme
COLORS = {
    'primary': '#4a046a',        # Deep purple
    'secondary': '#094880',      # Deep blue
    'accent': '#85e1f7',         # Light blue
    'white': '#ffffff',
    'light_gray': '#f8f9fa',
    'gray': '#6c757d',
    'dark_gray': '#343a40',
    'success': '#28a745',
    'purple_light': '#f5f3ff',
    'purple_100': '#ede9fe'
}

def create_gradient_background(width, height, color1, color2, direction='diagonal'):
    """Create a gradient background"""
    image = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(image)
    
    if direction == 'diagonal':
        # Create diagonal gradient
        for i in range(width):
            for j in range(height):
                # Calculate gradient factor
                factor = (i + j) / (width + height)
                r = int(int(color1[1:3], 16) * (1 - factor) + int(color2[1:3], 16) * factor)
                g = int(int(color1[3:5], 16) * (1 - factor) + int(color2[3:5], 16) * factor)
                b = int(int(color1[5:7], 16) * (1 - factor) + int(color2[5:7], 16) * factor)
                draw.point((i, j), (r, g, b))
    else:
        # Create vertical gradient
        for j in range(height):
            factor = j / height
            r = int(int(color1[1:3], 16) * (1 - factor) + int(color2[1:3], 16) * factor)
            g = int(int(color1[3:5], 16) * (1 - factor) + int(color2[3:5], 16) * factor)
            b = int(int(color1[5:7], 16) * (1 - factor) + int(color2[5:7], 16) * factor)
            draw.rectangle([0, j, width, j+1], fill=(r, g, b))
    
    return image

def add_glassmorphism_card(image, x, y, width, height, opacity=0.2):
    """Add glassmorphism card effect"""
    draw = ImageDraw.Draw(image)
    
    # Create semi-transparent white overlay
    overlay = Image.new('RGBA', (width, height), (255, 255, 255, int(255 * opacity)))
    card_image = Image.new('RGBA', image.size, (0, 0, 0, 0))
    card_image.paste(overlay, (x, y))
    
    # Draw border
    draw.rectangle([x, y, x + width, y + height], outline=(255, 255, 255, 80), width=2)
    
    return Image.alpha_composite(image.convert('RGBA'), card_image).convert('RGB')

def draw_text_with_shadow(draw, text, x, y, font, fill_color, shadow_color=(0, 0, 0, 80)):
    """Draw text with shadow effect"""
    # Draw shadow
    draw.text((x + 2, y + 2), text, font=font, fill=shadow_color)
    # Draw main text
    draw.text((x, y), text, font=font, fill=fill_color)

def create_homepage_screenshot(width, height, device_type):
    """Create homepage screenshot"""
    image = create_gradient_background(width, height, COLORS['primary'], COLORS['secondary'])
    draw = ImageDraw.Draw(image)
    
    # Try to load fonts
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 80)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Add header with logo
    header_y = 120
    draw.text((width//2, header_y), "Faith Klinik Ministries", 
              font=subtitle_font, fill=COLORS['white'], anchor="mm")
    draw.text((width//2, header_y + 50), "The Word ON FIRE 🔥", 
              font=small_font, fill=COLORS['purple_100'], anchor="mm")
    
    # Main title
    title_y = 300
    draw.text((width//2, title_y), "JESUS LOVES YOU", 
              font=title_font, fill=COLORS['white'], anchor="mm")
    
    # Subtitle
    subtitle_y = title_y + 120
    draw.text((width//2, subtitle_y), "A missions minded church,", 
              font=body_font, fill=COLORS['purple_100'], anchor="mm")
    draw.text((width//2, subtitle_y + 40), "supporting world evangelism", 
              font=body_font, fill=COLORS['purple_100'], anchor="mm")
    
    # Bible verse card
    card_y = subtitle_y + 120
    card_width = width - 80
    card_height = 200
    card_x = (width - card_width) // 2
    
    # Draw glassmorphism card
    overlay = Image.new('RGBA', (card_width, card_height), (255, 255, 255, 50))
    card_image = Image.new('RGBA', image.size, (0, 0, 0, 0))
    card_image.paste(overlay, (card_x, card_y))
    image = Image.alpha_composite(image.convert('RGBA'), card_image).convert('RGB')
    
    # Add card border
    draw.rectangle([card_x, card_y, card_x + card_width, card_y + card_height], 
                  outline=(255, 255, 255, 100), width=2)
    
    # Bible verse text
    verse_y = card_y + 40
    draw.text((width//2, verse_y), '"Rejoice in the Lord always.', 
              font=body_font, fill=COLORS['white'], anchor="mm")
    draw.text((width//2, verse_y + 40), 'I will say it again: Rejoice!"', 
              font=body_font, fill=COLORS['white'], anchor="mm")
    draw.text((width//2, verse_y + 100), "— Philippians 4:4", 
              font=small_font, fill=COLORS['purple_100'], anchor="mm")
    
    # Service times section
    service_y = card_y + card_height + 80
    draw.text((width//2, service_y), "Service Times", 
              font=subtitle_font, fill=COLORS['white'], anchor="mm")
    
    # Service time cards
    service_card_y = service_y + 80
    service_card_width = (width - 120) // 2
    service_card_height = 180
    
    # Prayer service card
    prayer_x = 40
    overlay = Image.new('RGBA', (service_card_width, service_card_height), (255, 255, 255, 50))
    card_image = Image.new('RGBA', image.size, (0, 0, 0, 0))
    card_image.paste(overlay, (prayer_x, service_card_y))
    image = Image.alpha_composite(image.convert('RGBA'), card_image).convert('RGB')
    
    draw.text((prayer_x + service_card_width//2, service_card_y + 40), "Sunday Prayer", 
              font=body_font, fill=COLORS['white'], anchor="mm")
    draw.text((prayer_x + service_card_width//2, service_card_y + 80), "9:30 AM - 11:00 AM", 
              font=small_font, fill=COLORS['white'], anchor="mm")
    
    # Main service card
    main_x = width - 40 - service_card_width
    overlay = Image.new('RGBA', (service_card_width, service_card_height), (255, 255, 255, 50))
    card_image = Image.new('RGBA', image.size, (0, 0, 0, 0))
    card_image.paste(overlay, (main_x, service_card_y))
    image = Image.alpha_composite(image.convert('RGBA'), card_image).convert('RGB')
    
    draw.text((main_x + service_card_width//2, service_card_y + 40), "Main Service", 
              font=body_font, fill=COLORS['white'], anchor="mm")
    draw.text((main_x + service_card_width//2, service_card_y + 80), "11:00 AM - 1:00 PM", 
              font=small_font, fill=COLORS['white'], anchor="mm")
    
    # Login button
    button_y = service_card_y + service_card_height + 80
    button_width = 300
    button_height = 60
    button_x = (width - button_width) // 2
    
    # Draw button background
    draw.rounded_rectangle([button_x, button_y, button_x + button_width, button_y + button_height], 
                          radius=30, fill=COLORS['white'])
    draw.text((width//2, button_y + 30), "Member Login", 
              font=body_font, fill=COLORS['primary'], anchor="mm")
    
    return image

def create_login_screenshot(width, height, device_type):
    """Create login screen screenshot"""
    image = Image.new('RGB', (width, height), COLORS['light_gray'])
    draw = ImageDraw.Draw(image)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except:
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Modal background
    modal_width = width - 80
    modal_height = 500
    modal_x = (width - modal_width) // 2
    modal_y = (height - modal_height) // 2
    
    # Draw modal
    draw.rounded_rectangle([modal_x, modal_y, modal_x + modal_width, modal_y + modal_height], 
                          radius=20, fill=COLORS['white'])
    draw.rounded_rectangle([modal_x, modal_y, modal_x + modal_width, modal_y + modal_height], 
                          radius=20, outline=COLORS['gray'], width=2)
    
    # Modal title
    title_y = modal_y + 40
    draw.text((width//2, title_y), "Member Login", 
              font=title_font, fill=COLORS['primary'], anchor="mm")
    
    # Email field
    field_y = title_y + 100
    field_width = modal_width - 60
    field_height = 50
    field_x = modal_x + 30
    
    draw.rounded_rectangle([field_x, field_y, field_x + field_width, field_y + field_height], 
                          radius=10, fill=COLORS['light_gray'], outline=COLORS['gray'], width=1)
    draw.text((field_x + 20, field_y + 25), "Email", 
              font=body_font, fill=COLORS['gray'], anchor="lm")
    
    # Password field
    field_y += 80
    draw.rounded_rectangle([field_x, field_y, field_x + field_width, field_y + field_height], 
                          radius=10, fill=COLORS['light_gray'], outline=COLORS['gray'], width=1)
    draw.text((field_x + 20, field_y + 25), "Password", 
              font=body_font, fill=COLORS['gray'], anchor="lm")
    
    # Login button
    button_y = field_y + 80
    button_width = field_width
    button_height = 50
    
    draw.rounded_rectangle([field_x, button_y, field_x + button_width, button_y + button_height], 
                          radius=10, fill=COLORS['primary'])
    draw.text((width//2, button_y + 25), "Login to Member Portal", 
              font=body_font, fill=COLORS['white'], anchor="mm")
    
    # Demo text
    demo_y = button_y + 80
    draw.text((width//2, demo_y), "Demo: Use any email/password to login", 
              font=small_font, fill=COLORS['gray'], anchor="mm")
    
    return image

def create_dashboard_screenshot(width, height, device_type):
    """Create member dashboard screenshot"""
    image = Image.new('RGB', (width, height), COLORS['light_gray'])
    draw = ImageDraw.Draw(image)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except:
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    header_height = 120
    draw.rectangle([0, 0, width, header_height], fill=COLORS['white'])
    draw.line([0, header_height, width, header_height], fill=COLORS['gray'], width=1)
    
    # Logo and title
    draw.text((40, 60), "Faith Klinik", font=title_font, fill=COLORS['dark_gray'], anchor="lm")
    draw.text((40, 90), "The Word ON FIRE 🔥", font=small_font, fill=COLORS['gray'], anchor="lm")
    
    # Welcome message
    welcome_y = header_height + 40
    draw.text((width//2, welcome_y), "Welcome to the Member Portal", 
              font=title_font, fill=COLORS['dark_gray'], anchor="mm")
    
    # Navigation tabs
    nav_y = welcome_y + 80
    nav_height = 60
    nav_items = ['Dashboard', 'Members', 'Leadership', 'Ministries', 'Finances']
    nav_width = width // len(nav_items)
    
    for i, item in enumerate(nav_items):
        nav_x = i * nav_width
        if i == 0:  # Active tab
            draw.rectangle([nav_x, nav_y, nav_x + nav_width, nav_y + nav_height], 
                          fill=COLORS['primary'])
            text_color = COLORS['white']
        else:
            draw.rectangle([nav_x, nav_y, nav_x + nav_width, nav_y + nav_height], 
                          fill=COLORS['white'], outline=COLORS['gray'])
            text_color = COLORS['gray']
        
        draw.text((nav_x + nav_width//2, nav_y + 30), item, 
                  font=body_font, fill=text_color, anchor="mm")
    
    # Dashboard content
    content_y = nav_y + nav_height + 40
    
    # Stats cards
    card_height = 120
    card_width = (width - 120) // 2
    card_margin = 40
    
    # Members card
    card_x = card_margin
    draw.rounded_rectangle([card_x, content_y, card_x + card_width, content_y + card_height], 
                          radius=15, fill=COLORS['white'], outline=COLORS['gray'], width=1)
    draw.text((card_x + 20, content_y + 20), "Total Members", 
              font=small_font, fill=COLORS['gray'], anchor="lt")
    draw.text((card_x + 20, content_y + 60), "247", 
              font=title_font, fill=COLORS['primary'], anchor="lt")
    
    # Ministries card
    card_x = width - card_margin - card_width
    draw.rounded_rectangle([card_x, content_y, card_x + card_width, content_y + card_height], 
                          radius=15, fill=COLORS['white'], outline=COLORS['gray'], width=1)
    draw.text((card_x + 20, content_y + 20), "Active Ministries", 
              font=small_font, fill=COLORS['gray'], anchor="lt")
    draw.text((card_x + 20, content_y + 60), "12", 
              font=title_font, fill=COLORS['primary'], anchor="lt")
    
    # Recent activity
    activity_y = content_y + card_height + 40
    draw.text((40, activity_y), "Recent Activity", 
              font=body_font, fill=COLORS['dark_gray'], anchor="lt")
    
    # Activity items
    activity_items = [
        "New member: Sarah Johnson joined Youth Ministry",
        "Upcoming: Prayer Meeting - Friday 6:00 PM",
        "Ministry Update: Food Pantry served 45 families",
        "Leadership Meeting scheduled for next Sunday"
    ]
    
    for i, item in enumerate(activity_items):
        item_y = activity_y + 50 + (i * 60)
        draw.rounded_rectangle([40, item_y, width - 40, item_y + 50], 
                              radius=10, fill=COLORS['white'], outline=COLORS['gray'], width=1)
        draw.text((60, item_y + 25), item, 
                  font=small_font, fill=COLORS['dark_gray'], anchor="lm")
    
    return image

def create_member_directory_screenshot(width, height, device_type):
    """Create member directory screenshot"""
    image = Image.new('RGB', (width, height), COLORS['light_gray'])
    draw = ImageDraw.Draw(image)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except:
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    header_height = 120
    draw.rectangle([0, 0, width, header_height], fill=COLORS['white'])
    draw.text((width//2, 60), "Member Directory", 
              font=title_font, fill=COLORS['dark_gray'], anchor="mm")
    
    # Search bar
    search_y = header_height + 20
    search_height = 50
    search_margin = 40
    
    draw.rounded_rectangle([search_margin, search_y, width - search_margin, search_y + search_height], 
                          radius=25, fill=COLORS['white'], outline=COLORS['gray'], width=1)
    draw.text((search_margin + 20, search_y + 25), "Search members...", 
              font=body_font, fill=COLORS['gray'], anchor="lm")
    
    # Member list
    members = [
        {"name": "Rev. Ebenezer Adarquah-Yiadom", "role": "Executive Pastor", "ministry": "Leadership"},
        {"name": "Rev. Lucie Adarquah-Yiadom", "role": "Resident Pastor", "ministry": "Leadership"},
        {"name": "Sarah Johnson", "role": "Worship Leader", "ministry": "Worship Ministry"},
        {"name": "Michael Davis", "role": "Youth Leader", "ministry": "Youth Ministry"},
        {"name": "Gloria Adarquah-Yiadom", "role": "Elder", "ministry": "Prayer Ministry"},
        {"name": "Patricia Brown", "role": "Ministry Head", "ministry": "Prayer Ministry"},
        {"name": "James Miller", "role": "Deacon", "ministry": "Outreach Ministry"},
        {"name": "Mary Thompson", "role": "Ministry Head", "ministry": "Hospitality"}
    ]
    
    list_y = search_y + search_height + 20
    item_height = 80
    
    for i, member in enumerate(members):
        if list_y + (i * item_height) > height - 100:
            break
            
        item_y = list_y + (i * item_height)
        
        # Member card
        draw.rounded_rectangle([40, item_y, width - 40, item_y + item_height - 10], 
                              radius=10, fill=COLORS['white'], outline=COLORS['gray'], width=1)
        
        # Profile circle
        circle_size = 50
        circle_x = 60
        circle_y = item_y + 15
        draw.ellipse([circle_x, circle_y, circle_x + circle_size, circle_y + circle_size], 
                    fill=COLORS['primary'])
        
        # Member info
        info_x = circle_x + circle_size + 20
        draw.text((info_x, item_y + 15), member["name"], 
                  font=body_font, fill=COLORS['dark_gray'], anchor="lt")
        draw.text((info_x, item_y + 40), member["role"], 
                  font=small_font, fill=COLORS['gray'], anchor="lt")
        draw.text((info_x, item_y + 60), member["ministry"], 
                  font=small_font, fill=COLORS['primary'], anchor="lt")
    
    return image

def create_ministry_management_screenshot(width, height, device_type):
    """Create ministry management screenshot"""
    image = Image.new('RGB', (width, height), COLORS['light_gray'])
    draw = ImageDraw.Draw(image)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except:
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    header_height = 120
    draw.rectangle([0, 0, width, header_height], fill=COLORS['white'])
    draw.text((width//2, 60), "Ministry Management", 
              font=title_font, fill=COLORS['dark_gray'], anchor="mm")
    
    # Ministries
    ministries = [
        {"name": "Worship Ministry", "head": "Sarah Johnson", "members": 12, "color": COLORS['primary']},
        {"name": "Youth Ministry", "head": "Michael Davis", "members": 25, "color": COLORS['secondary']},
        {"name": "Children's Ministry", "head": "Grace Wilson", "members": 8, "color": COLORS['success']},
        {"name": "Prayer Ministry", "head": "Patricia Brown", "members": 15, "color": COLORS['primary']},
        {"name": "Outreach Ministry", "head": "James Miller", "members": 18, "color": COLORS['secondary']},
        {"name": "Hospitality Ministry", "head": "Mary Thompson", "members": 10, "color": COLORS['success']}
    ]
    
    list_y = header_height + 40
    item_height = 120
    
    for i, ministry in enumerate(ministries):
        if list_y + (i * item_height) > height - 100:
            break
            
        item_y = list_y + (i * item_height)
        
        # Ministry card
        draw.rounded_rectangle([40, item_y, width - 40, item_y + item_height - 20], 
                              radius=15, fill=COLORS['white'], outline=COLORS['gray'], width=1)
        
        # Color indicator
        draw.rectangle([40, item_y, 48, item_y + item_height - 20], fill=ministry["color"])
        
        # Ministry info
        info_x = 70
        draw.text((info_x, item_y + 20), ministry["name"], 
                  font=body_font, fill=COLORS['dark_gray'], anchor="lt")
        draw.text((info_x, item_y + 50), f"Head: {ministry['head']}", 
                  font=small_font, fill=COLORS['gray'], anchor="lt")
        draw.text((info_x, item_y + 75), f"Members: {ministry['members']}", 
                  font=small_font, fill=ministry["color"], anchor="lt")
        
        # Action button
        button_x = width - 140
        button_y = item_y + 35
        draw.rounded_rectangle([button_x, button_y, button_x + 80, button_y + 30], 
                              radius=15, fill=ministry["color"])
        draw.text((button_x + 40, button_y + 15), "View", 
                  font=small_font, fill=COLORS['white'], anchor="mm")
    
    return image

def create_screenshots():
    """Create all screenshots for both iOS and Android"""
    
    # iPhone screenshot sizes
    iphone_sizes = {
        "iPhone_6.7": (1320, 2868),  # iPhone 15 Pro Max
        "iPhone_6.1": (1179, 2556),  # iPhone 15
        "iPhone_5.5": (1242, 2208),  # iPhone 8 Plus
    }
    
    # iPad screenshot sizes
    ipad_sizes = {
        "iPad_12.9": (2048, 2732),   # iPad Pro 12.9"
        "iPad_11": (1668, 2388),     # iPad Air 11"
    }
    
    # Android screenshot sizes
    android_sizes = {
        "Android_Phone": (1080, 1920),
        "Android_Tablet": (1600, 2560),
    }
    
    screenshot_functions = [
        ("01_Homepage", create_homepage_screenshot),
        ("02_Login", create_login_screenshot),
        ("03_Dashboard", create_dashboard_screenshot),
        ("04_Members", create_member_directory_screenshot),
        ("05_Ministries", create_ministry_management_screenshot),
    ]
    
    # Create iPhone screenshots
    print("Creating iPhone screenshots...")
    for device, (width, height) in iphone_sizes.items():
        device_dir = f"screenshots/{device}"
        os.makedirs(device_dir, exist_ok=True)
        
        for name, func in screenshot_functions:
            print(f"  Creating {name} for {device}...")
            screenshot = func(width, height, device)
            screenshot.save(f"{device_dir}/{name}.png")
    
    # Create iPad screenshots
    print("Creating iPad screenshots...")
    for device, (width, height) in ipad_sizes.items():
        device_dir = f"screenshots/{device}"
        os.makedirs(device_dir, exist_ok=True)
        
        for name, func in screenshot_functions:
            print(f"  Creating {name} for {device}...")
            screenshot = func(width, height, device)
            screenshot.save(f"{device_dir}/{name}.png")
    
    # Create Android screenshots
    print("Creating Android screenshots...")
    for device, (width, height) in android_sizes.items():
        device_dir = f"screenshots/{device}"
        os.makedirs(device_dir, exist_ok=True)
        
        for name, func in screenshot_functions:
            print(f"  Creating {name} for {device}...")
            screenshot = func(width, height, device)
            screenshot.save(f"{device_dir}/{name}.png")
    
    print("\n✅ All screenshots created successfully!")
    print(f"📁 Location: {os.path.abspath('screenshots')}")
    print("\n📱 Available sizes:")
    print("iPhone: 6.7\", 6.1\", 5.5\"")
    print("iPad: 12.9\", 11\"")
    print("Android: Phone, Tablet")
    print("\n🎬 Screenshots:")
    for name, _ in screenshot_functions:
        print(f"  {name}")

if __name__ == "__main__":
    create_screenshots()