from PIL import Image, ImageDraw
import os
import shutil

# Create directories if they don't exist
os.makedirs('iOSAuthApp/iOSAuthApp/Assets.xcassets/AppIcon.appiconset', exist_ok=True)

# Define all required icon sizes for iOS with exact pixel dimensions
icon_sizes = [
    # iPhone icons
    (40, 'Icon-20@2x.png'),      # 20pt@2x (40x40 px)
    (60, 'Icon-20@3x.png'),      # 20pt@3x (60x60 px)
    (29, 'Icon-29.png'),         # 29pt@1x (29x29 px)
    (58, 'Icon-29@2x.png'),      # 29pt@2x (58x58 px)
    (87, 'Icon-29@3x.png'),      # 29pt@3x (87x87 px)
    (80, 'Icon-40@2x.png'),      # 40pt@2x (80x80 px)
    (120, 'Icon-40@3x.png'),     # 40pt@3x (120x120 px)
    (120, 'Icon-60@2x.png'),     # 60pt@2x (120x120 px) - REQUIRED
    (180, 'Icon-60@3x.png'),     # 60pt@3x (180x180 px) - REQUIRED
    
    # iPad icons
    (20, 'Icon-20.png'),         # 20pt@1x (20x20 px)
    (40, 'Icon-20@2x-1.png'),    # 20pt@2x (40x40 px)
    (29, 'Icon-29-1.png'),       # 29pt@1x (29x29 px)
    (58, 'Icon-29@2x-1.png'),    # 29pt@2x (58x58 px)
    (40, 'Icon-40.png'),         # 40pt@1x (40x40 px)
    (80, 'Icon-40@2x-1.png'),    # 40pt@2x (80x80 px)
    (76, 'Icon-76.png'),         # 76pt@1x (76x76 px)
    (152, 'Icon-76@2x.png'),     # 76pt@2x (152x152 px) - REQUIRED
    (167, 'Icon-83.5@2x.png'),   # 83.5pt@2x (167x167 px) - REQUIRED
    
    # App Store icon
    (1024, 'Icon-1024.png'),     # 1024pt@1x (1024x1024 px) - REQUIRED
]

# Create a simple icon for each size
for size, filename in icon_sizes:
    # Create a new image with a blue background
    img = Image.new('RGB', (size, size), color=(0, 122, 255))
    
    # Create a drawing context
    draw = ImageDraw.Draw(img)
    
    # Draw a white circle in the center
    circle_radius = size // 3
    circle_center = (size // 2, size // 2)
    circle_bbox = (
        circle_center[0] - circle_radius,
        circle_center[1] - circle_radius,
        circle_center[0] + circle_radius,
        circle_center[1] + circle_radius
    )
    draw.ellipse(circle_bbox, fill=(255, 255, 255))
    
    # Draw a smaller blue circle inside
    inner_radius = circle_radius // 2
    inner_bbox = (
        circle_center[0] - inner_radius,
        circle_center[1] - inner_radius,
        circle_center[0] + inner_radius,
        circle_center[1] + inner_radius
    )
    draw.ellipse(inner_bbox, fill=(0, 122, 255))
    
    # Save the icon with high quality in the asset catalog
    asset_path = os.path.join('iOSAuthApp/iOSAuthApp/Assets.xcassets/AppIcon.appiconset', filename)
    img.save(asset_path, quality=100)
    print(f"Created {asset_path} ({size}x{size} px)")

print("All app icon files created successfully with proper dimensions!")
print("\nKey icons created:")
print("- iPhone: 120x120 px (Icon-60@2x.png)")
print("- iPhone: 180x180 px (Icon-60@3x.png)")
print("- iPad: 152x152 px (Icon-76@2x.png)")
print("- iPad Pro: 167x167 px (Icon-83.5@2x.png)")
print("- App Store: 1024x1024 px (Icon-1024.png)")
