#!/bin/bash

# Make the script executable
chmod +x fix_remaining_issues.sh

# Create a symbolic link to MealAnalysis.swift in each directory that needs it
ln -sf ../Models/MealAnalysis.swift iOSAuthApp/iOSAuthApp/Controllers/
ln -sf ../Models/MealAnalysis.swift iOSAuthApp/iOSAuthApp/Services/
ln -sf ../Models/MealAnalysis.swift iOSAuthApp/iOSAuthApp/Views/

# Add import statements to each file
echo "import Foundation" > temp.swift
echo "import UIKit" >> temp.swift
echo "" >> temp.swift
cat iOSAuthApp/iOSAuthApp/Models/MealAnalysis.swift >> temp.swift
mv temp.swift iOSAuthApp/iOSAuthApp/Models/MealAnalysis.swift

# Make sure MealAnalysis.swift is included in the Xcode project
echo "Please make sure to add MealAnalysis.swift to your Xcode project:"
echo "1. Open your Xcode project"
echo "2. Right-click on the 'Models' group in the Project Navigator"
echo "3. Select 'Add Files to 'iOSAuthApp'...'"
echo "4. Navigate to and select iOSAuthApp/iOSAuthApp/Models/MealAnalysis.swift"
echo "5. Make sure 'Add to targets' has 'iOSAuthApp' checked"
echo "6. Click 'Add'"
echo ""
echo "Then do the same for OpenAIService.swift in the Services group."
echo ""
echo "After adding these files, clean and rebuild your project."
