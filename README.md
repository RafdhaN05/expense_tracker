# PAWSE - Expense Tracker Mobile Application
PAWSE is a clean and responsive Expense Tracker mobile application developed using Flutter for the CyphLab Flutter Developer Internship selection task.

The application allows users to add, edit, delete, categorize, search, and filter their expenses. It also provides monthly expense summaries, category-wise spending information, and a visual expense chart. Firebase is used for authentication and real-time expense data storage. The application also supports Light Mode and Dark Mode.

## Project Setup Instructions
### Requirements
* Flutter SDK
* VS Code or Android Studio
* Android physical device or Android Emulator
* Firebase account

The application was developed using VS Code and tested on an Android physical device. It can also be opened and run using Android Studio.

### Step-by-Step Installation
### Step 1: Create the Flutter Project
The Flutter project was initialized using:

```bash
flutter create . --org com.rafdha.expensetracker
```

### Step 2: Project Structure
The main project structure under `lib/` is organized as follows:
```text
lib/
├── constants/
├── models/
├── providers/
├── screens/
├── services/
├── theme/
└── widgets/
```

* `constants/` - Application constants such as colors
* `models/` - Expense data models
* `providers/` - State management providers
* `screens/` - Application screens
* `services/` - Firebase Authentication and Firestore services
* `theme/` - Light and Dark theme configurations
* `widgets/` - Reusable UI components used for the expense screens

### Step 3: Install Dependencies
The following packages were added to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^4.15.0
  cloud_firestore: ^6.10.0
  provider: ^6.1.5+1
  intl: ^0.20.3
  fl_chart: ^1.2.0
  firebase_auth: ^6.7.0
```

Run the following command to install the packages:
```bash
flutter pub get
```

### Step 4: Firebase Configuration
For the Firebase setup, I created a Firebase project named expense-tracker-app.
I enabled Email/Password Authentication in Firebase Authentication and created a Cloud Firestore Database to store the users' expense data.
I then connected the Android application to Firebase using the application's package name and downloaded the google-services.json file. I placed this file inside:
android/app/google-services.json
After that, I configured the required Android Gradle and Firebase settings so that the Flutter application could connect properly with Firebase services.

### Step 5: Run the Application
Connecting to an Android physical device or starting an Android emulator:

```bash
flutter run
```

## Implementation Order
The application was developed in the following order:
1. Welcome Screen
2. Authentication Screens
   * Register Screen
   * Sign In Screen
   * Forgot Password Screen
3. Main Navigation Structure
4. Profile Screen
5. Light and Dark Theme
6. Add Expense Form
7. Expenses Screen
8. History Screen
9. Dashboard Screen

# Features Implemented
## Welcome Screen
* PAWSE logo
* Get Started button
* Navigation to the Sign In screen

## Sign In Screen
* Email and password input fields
* Password visibility toggle
* Field-level validation
* Validation messages for missing or incorrect input
* Firebase Authentication integration
* User-friendly handling of authentication errors such as incorrect email or password
* Navigation to Register and Forgot Password screens

## Register Screen
* New account registration using Firebase Authentication
* Email validation
* Password validation with a minimum requirement of 8 characters
* Field-level validation messages
* Handling of duplicate account registration errors
* Navigation back to the Sign In screen for existing users

## Forgot Password Screen
* Email input for password recovery
* Email format validation
* An informational message is displayed to explain that the password recovery feature is not currently active in this evaluation version.

## Main Navigation
The application uses a bottom navigation bar with four main sections:
* Dashboard
* Add Expense
* History
* Profile

## Expenses Screen
* Search bar for finding expenses
* Category filtering using horizontal filter chips
* Available categories:
  * All
  * Food
  * Transport
  * Bills
  * Shopping
  * Entertainment
  * Health
  * Education
  * Other
* Expense cards showing:
  * Title
  * Category
  * Date
  * Note, when available
  * Amount in Rs.
* Edit existing expenses
* Delete expenses with a confirmation dialog
* Updated expense information is reflected immediately on the screen
* Firebase Firestore synchronization for expense data
* Tapping an expense records the transaction in the History section and displays a confirmation message

## Add Expense Form
* Title input
* Amount input in Rs.
* Category selection
* Date selection
* Optional note/description
* Form validation
* Required amount validation
* Required title validation
* Calendar date picker
* Current and future dates can be selected
* Past dates are disabled
* Expense information is saved to Firebase
* The expense list updates after adding or updating an expense

## Dashboard Screen
* Month-wise navigation
* Total expense summary for the selected month
* View All Expenses shortcut
* Donut chart showing category-wise expense distribution
* Category-wise spending breakdown
* Total amount spent for each category
* Percentage contribution for each category
* Linear progress bars for category spending

## History Screen
* Displays an activity log of expenses selected from the Expenses screen
* Individual history items can be removed
* Clear All option for removing the complete activity history

## Profile Screen
* Displays the authenticated user's email address
* User profile icon
* Manual Light Mode and Dark Mode toggle
* Support for following the device's system theme setting
* Sign Out functionality
* Returns the user to the Welcome Screen after signing out

# Technologies and Packages Used
### Flutter
Used as the main cross-platform framework for developing the mobile application.

### Dart
Used as the programming language for the application.

### Firebase Core
`firebase_core` is used to initialize and connect the Flutter application with Firebase services.

### Firebase Authentication
`firebase_auth` is used for user registration, sign in, authentication state management, and sign out functionality.

### Cloud Firestore
`cloud_firestore` is used as the cloud database for storing and synchronizing expense data in real time.

### Provider
`provider` is used for application state management, including:
* ExpenseProvider
* HistoryProvider
* ThemeProvider

### FL Chart
`fl_chart` is used to create the expense category distribution donut chart on the Dashboard.

### Intl
`intl` is used for date and currency formatting.

### Cupertino Icons
`cupertino_icons` is used to provide standard application icons.

# AI Tools Used
AI tools were used during development as supporting tools. The generated suggestions and code were reviewed, modified, tested, and integrated into the application based on the project requirements.

### Google AI Studio
Google AI Studio was used for:

* Planning and structuring parts of the application
* Fixing and updating code
* Improving Firestore data queries
* Working on theme implementation
* Creating and improving the expense chart
* Improving form validation and error handling

### ChatGPT
ChatGPT was used for:

* Generating the PAWSE application logo
* Debugging Android Gradle build and cache-related errors
* Troubleshooting layout overflow issues
* Improving search filtering
* Implementing immediate UI updates after expense changes
* Troubleshooting and improving the profile screen and related functionality

I reviewed and modified the AI-assisted code during development and tested the final implementation in the Flutter application.
