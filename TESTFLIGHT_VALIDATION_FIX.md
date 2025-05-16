# TestFlight Validation Fix Guide

This document provides a comprehensive guide to fix the TestFlight validation errors related to app icons and Info.plist configuration.

## Issues Fixed

1. Missing required icon files:
   - 120×120 px iPhone icon
   - 152×152 px iPad icon

2. Missing Info.plist configuration:
   - CFBundleIconName value
   - Background modes configuration

## Solution Implemented

### 1. App Icons in Asset Catalog

All required app icons have been created and properly configured in the asset catalog:

- **iPhone icons**:
  - 120×120 px (Icon-60@2x.png) - Required for iPhone @2x
  - 180×180 px (Icon-60@3x.png) - Required for iPhone @3x Retina

- **iPad icons**:
  - 152×152 px (Icon-76@2x.png) - Required for iPad Retina @2x
  - 167×167 px (Icon-83.5@2x.png) - Required for iPad Pro @2x

- **App Store icon**:
  - 1024×1024 px (Icon-1024.png) - Required for App Store submission

- **Additional icons** for completeness:
  - Various notification and settings icons (20pt, 29pt, 40pt) in different scales

### 2. Info.plist Configuration

The Info.plist file has been updated with the following changes:

1. **App Icon Configuration**:
   ```xml
   <key>CFBundleIconName</key>
   <string>AppIcon</string>
   ```

2. **Background Modes Configuration**:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>fetch</string>
       <string>processing</string>
   </array>
   <key>BGTaskSchedulerPermittedIdentifiers</key>
   <array>
       <string>com.kopeck.app.refresh</string>
       <string>com.kopeck.app.processing</string>
   </array>
   ```

3. **iPad Interface Orientations**:
   ```xml
   <key>UISupportedInterfaceOrientations_iPad</key>
   <array>
       <string>UIInterfaceOrientationPortrait</string>
       <string>UIInterfaceOrientationPortraitUpsideDown</string>
       <string>UIInterfaceOrientationLandscapeLeft</string>
       <string>UIInterfaceOrientationLandscapeRight</string>
   </array>
   ```

## Steps to Verify the Fix

1. **Clean the Build Folder**:
   - In Xcode, go to Product > Clean Build Folder (Shift+Command+K)

2. **Rebuild the App**:
   - Build the app again (Command+B)

3. **Archive and Submit**:
   - Create a new archive (Product > Archive)
   - Submit the archive to TestFlight

## Technical Details

### App Icon Requirements

For iOS apps targeting iOS 10 and later, the following icon sizes are required:

- **iPhone**:
  - 120×120 px (60pt@2x) - iPhone with Retina display
  - 180×180 px (60pt@3x) - iPhone with Retina HD display

- **iPad**:
  - 152×152 px (76pt@2x) - iPad with Retina display
  - 167×167 px (83.5pt@2x) - iPad Pro

- **App Store**:
  - 1024×1024 px - Required for App Store submission

### Info.plist Requirements

1. **CFBundleIconName**:
   - Required for apps built with iOS 11+ SDK
   - Must match the name of the app icon set in the asset catalog (typically "AppIcon")

2. **Background Processing**:
   - If using the "processing" background mode, you must include BGTaskSchedulerPermittedIdentifiers
   - Each identifier should match what you register in code with BGTaskScheduler

## References

- [Apple Documentation: App Icon](https://developer.apple.com/documentation/bundleresources/information_property_list/user_interface)
- [Apple Documentation: Asset Catalogs](http://help.apple.com/xcode/mac/current/#/dev10510b1f7)
- [Apple Documentation: Background Tasks](https://developer.apple.com/documentation/backgroundtasks)
