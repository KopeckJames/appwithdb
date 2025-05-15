# iOS Authentication App

This is a simple iOS app that demonstrates local authentication using Core Data for storage. The app includes:

- User registration
- User login/logout
- Secure local storage using Core Data

## Features

- **User Authentication**: Register and login with email and password
- **Local Database**: Store user information securely using Core Data
- **SwiftUI Interface**: Modern UI built with SwiftUI

## Project Structure

```
iOSAuthApp/
├── iOSAuthApp/
│   ├── Models/
│   │   ├── User.swift
│   │   └── AuthModel.xcdatamodeld
│   ├── Views/
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   └── HomeView.swift
│   ├── Controllers/
│   │   └── AuthManager.swift
│   ├── AppDelegate.swift
│   ├── AuthApp.swift
│   └── Info.plist
└── iOSAuthApp.xcodeproj/
```

## How to Use

1. Open the project in Xcode by opening the `iOSAuthApp.xcodeproj` file
2. Build and run the app on an iPhone 16 Pro simulator or device
3. Register a new user account
4. Login with your credentials
5. You'll be taken to the home screen when authenticated
6. Use the logout button to return to the login screen

## Security Notes

- In a production app, passwords should be hashed before storage
- This example uses simple string comparison for demonstration purposes
- Consider adding biometric authentication for enhanced security

## Requirements

- iOS 16.0+
- Xcode 16.0+
- Swift 5.0+

## Next Steps

- Add password hashing for security
- Implement biometric authentication (Face ID/Touch ID)
- Add data persistence for user sessions
- Expand the user profile with additional information