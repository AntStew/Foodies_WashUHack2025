# Foodies - Smart Fridge Management App

**WashU Hackathon 2025 Project**

A Flutter application that uses AI to help you manage your fridge inventory and generate personalized recipes based on available ingredients.

**LINK** https://foodies-e099a.web.app/

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Architecture](#project-architecture)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Implementation Guide](#implementation-guide)
- [Firebase Setup](#firebase-setup)
- [OpenAI Integration](#openai-integration)
- [Database Schema](#database-schema)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## 🎯 Overview

Foodies is an intelligent fridge management app that combines computer vision and natural language processing to solve the "What should I cook?" problem. Simply take a photo of your fridge, and our AI will:

1. **Identify** all items and their quantities
2. **Track** your inventory in real-time
3. **Generate** personalized recipes based on what you have
4. **Consider** your dietary restrictions and cuisine preferences

### Why Foodies?

- 🍎 **Reduce Food Waste**: Know what you have before it expires
- 👨‍🍳 **Cook Smarter**: Get recipes tailored to your ingredients
- 🥗 **Eat Healthier**: Respects dietary restrictions and allergies
- 📱 **Always Accessible**: Cross-platform (Web, iOS, Android)

---

## ✨ Features

### Core Features

- ✅ **User Authentication**
  - Email/password signup and login via Firebase Auth
  - Secure session management
  - Auto-routing based on auth state

- ✅ **Smart Onboarding**
  - First-time user questionnaire
  - Dietary restrictions (Vegetarian, Vegan, Gluten-Free, etc.)
  - Cuisine preferences (Italian, Mexican, Chinese, etc.)
  - Allergy tracking
  - Default serving size

- ✅ **AI-Powered Fridge Scanning**
  - Camera or gallery image selection
  - OpenAI GPT-4o Vision API for ingredient detection
  - Automatic extraction of:
    - Item names
    - Quantities
    - Categories (Dairy, Produce, Meat, etc.)
    - Freshness levels

- ✅ **Intelligent Recipe Generation**
  - Personalized recipes using OpenAI GPT-4o
  - Considers available ingredients
  - Respects dietary restrictions
  - Matches cuisine preferences
  - Adjusts for serving size

- ✅ **Recipe Management**
  - Save favorite recipes
  - View detailed cooking instructions
  - Track which fridge items were used
  - Delete recipes you don't want

- ✅ **Real-Time Inventory**
  - Live updates via Firestore
  - Add/remove items
  - View item details
  - Clear entire fridge

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.32.8
- **Language**: Dart
- **UI**: Material Design 3
- **State Management**: Provider (minimal)
- **Image Handling**: image_picker

### Backend & Services
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **AI Vision**: OpenAI GPT-4o Vision API
- **AI Text**: OpenAI GPT-4o Chat API

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  firebase_storage: ^12.3.6
  firebase_analytics: ^11.3.4

  # HTTP & API
  http: ^1.2.0

  # Image handling
  image_picker: ^1.0.7

  # State Management
  provider: ^6.1.2

  # Utilities
  intl: ^0.19.0
  cupertino_icons: ^1.0.8
```

---

## 🏗️ Project Architecture

### Architecture Pattern: Clean Architecture with Services

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Screens, Widgets, UI Components)      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Business Logic Layer           │
│     (Services, State Management)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            Data Layer                   │
│  (Models, Firebase, OpenAI, Storage)    │
└─────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Single Responsibility**: Each class/file has one job
3. **Dependency Injection**: Services are injected where needed
4. **Stateless/Stateful Balance**: Minimize state, use streams for real-time data

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Firebase account (free tier works)
- OpenAI API key with credits
- Code editor (VS Code, Android Studio, IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd Foodies_WashUHack2025
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Deploy Cloud Functions** (Required for AI features)

   The app uses Firebase Cloud Functions to securely handle OpenAI API calls. Your API key is stored on Firebase servers, not in code.

   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Login to Firebase
   firebase login

   # Install function dependencies
   cd functions
   npm install
   cd ..

   # Set your OpenAI API key as a secret
   firebase functions:secrets:set OPENAI_API_KEY
   # (paste your API key when prompted)

   # Deploy the functions
   firebase deploy --only functions
   ```

4. **Run the app**
   ```bash
   # For web
   flutter run -d chrome

   # For Android emulator
   flutter run -d android

   # For iOS simulator (Mac only)
   flutter run -d ios
   ```

### First Run

1. Sign up with any email (e.g., `test@gmail.com` / `aaaa1111`)
2. Complete the questionnaire with your preferences
3. Upload a fridge photo or test image
4. Wait for AI analysis (~5-10 seconds)
5. Generate a recipe based on detected items
6. Save and view your recipes

---

## 🔄 How It Works

### 1. Authentication Flow

```
User opens app
    ├─> Not logged in? → Login Screen
    │       ├─> Sign Up → Create account + User profile
    │       └─> Login → Verify credentials
    │
    └─> Logged in?
        ├─> Questionnaire not complete? → Questionnaire Screen
        └─> Complete? → Home Screen
```

**Implementation**: `lib/main.dart` → `InitialScreen` checks auth state

### 2. Fridge Scanning Flow

```
User clicks "Scan Fridge"
    ↓
Choose Image (camera or gallery)
    ↓
Image preview displayed
    ↓
Click "Analyze Fridge"
    ↓
Upload to Firebase Storage
    ↓
Send image URL to OpenAI Vision API
    ↓
Parse JSON response
    ↓
Extract items: name, category, quantity, freshness
    ↓
Save each item to Firestore
    ↓
Real-time update in Home Screen
```

**Key Files**:
- `lib/screens/fridge/fridge_scan_screen.dart` - UI and logic
- `lib/services/storage_service.dart` - Firebase Storage upload
- `lib/services/openai_service.dart` - Vision API call
- `lib/services/firestore_service.dart` - Save items

### 3. Recipe Generation Flow

```
User clicks "Generate Recipe"
    ↓
Fetch user preferences from Firestore
    ↓
Fetch all fridge items
    ↓
Build prompt with:
    - Available ingredients
    - Dietary restrictions
    - Cuisine preferences
    - Serving size
    ↓
Send to OpenAI Chat API
    ↓
Parse JSON recipe response
    ↓
Display recipe with:
    - Title, description
    - Ingredients, instructions
    - Cook/prep times
    ↓
User can save to Firestore
```

**Key Files**:
- `lib/screens/recipes/recipe_generate_screen.dart` - UI
- `lib/services/openai_service.dart` - Chat API call
- `lib/models/recipe_model.dart` - Recipe data structure

### 4. Data Synchronization

All data uses **real-time streams** via Firestore:

```dart
// Example: Fridge items auto-update
StreamBuilder<List<FridgeItem>>(
  stream: firestoreService.getFridgeItems(userId),
  builder: (context, snapshot) {
    // UI rebuilds automatically when data changes
  }
)
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init, routing
├── firebase_options.dart              # Firebase configuration (auto-generated)
│
├── models/                            # Data Models (Plain Dart Objects)
│   ├── user_model.dart               # User profile + preferences
│   ├── fridge_item_model.dart        # Individual fridge item
│   └── recipe_model.dart             # Recipe with instructions
│
├── services/                          # Business Logic & External APIs
│   ├── auth_service.dart             # Firebase Authentication wrapper
│   ├── firestore_service.dart        # Firestore CRUD operations
│   ├── storage_service.dart          # Firebase Storage (images)
│   └── openai_service.dart           # OpenAI Vision + Chat APIs
│
├── screens/                           # UI Screens (Stateful/Stateless Widgets)
│   ├── auth/
│   │   ├── login_screen.dart         # Email/password login
│   │   ├── signup_screen.dart        # New user registration
│   │   └── questionnaire_screen.dart # First-time user preferences
│   │
│   ├── home/
│   │   └── home_screen.dart          # Main dashboard with fridge list
│   │
│   ├── fridge/
│   │   └── fridge_scan_screen.dart   # Camera/gallery + AI analysis
│   │
│   └── recipes/
│       ├── recipe_generate_screen.dart   # AI recipe generation
│       ├── saved_recipes_screen.dart     # List of saved recipes
│       └── recipe_detail_screen.dart     # Full recipe view
│
├── routes/
│   └── app_routes.dart               # Navigation configuration
│
└── utils/
    └── constants.dart                # API keys, constants (gitignored)
```

### File Responsibilities

| File | Purpose | Key Methods |
|------|---------|-------------|
| `auth_service.dart` | Manage user authentication | `signUp()`, `signIn()`, `signOut()` |
| `firestore_service.dart` | Database operations | `createUserProfile()`, `getFridgeItems()`, `saveRecipe()` |
| `storage_service.dart` | Upload images | `uploadFridgeImage()`, `uploadFridgeImageWeb()` |
| `openai_service.dart` | AI API calls | `analyzeFridgeImage()`, `generateRecipe()` |
| `home_screen.dart` | Main UI | Display fridge items with real-time updates |
| `fridge_scan_screen.dart` | Image capture + analysis | Handle camera, upload, parse AI results |
| `recipe_generate_screen.dart` | Recipe creation | Call AI, display result, save option |

---

## 💻 Implementation Guide

### Adding a New Screen

1. **Create the screen file**
   ```dart
   // lib/screens/new_feature/my_screen.dart
   import 'package:flutter/material.dart';

   class MyScreen extends StatefulWidget {
     const MyScreen({super.key});

     @override
     State<MyScreen> createState() => _MyScreenState();
   }

   class _MyScreenState extends State<MyScreen> {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('My Screen')),
         body: Center(child: Text('New Feature')),
       );
     }
   }
   ```

2. **Add route**
   ```dart
   // lib/routes/app_routes.dart
   class AppRoutes {
     static const String myScreen = '/my-screen';

     static Map<String, WidgetBuilder> routes = {
       // ... existing routes
       myScreen: (context) => const MyScreen(),
     };
   }
   ```

3. **Navigate to it**
   ```dart
   Navigator.pushNamed(context, '/my-screen');
   ```

### Adding a New Service

1. **Create service file**
   ```dart
   // lib/services/my_service.dart
   class MyService {
     Future<void> doSomething() async {
       // Implementation
     }
   }
   ```

2. **Use in screens**
   ```dart
   final _myService = MyService();

   void _callService() async {
     await _myService.doSomething();
   }
   ```

### Adding a New Model

1. **Create model file**
   ```dart
   // lib/models/my_model.dart
   import 'package:cloud_firestore/cloud_firestore.dart';

   class MyModel {
     final String id;
     final String name;

     MyModel({required this.id, required this.name});

     // To Firestore
     Map<String, dynamic> toMap() {
       return {'name': name};
     }

     // From Firestore
     factory MyModel.fromMap(String id, Map<String, dynamic> map) {
       return MyModel(
         id: id,
         name: map['name'] ?? '',
       );
     }
   }
   ```

### Integrating a New AI Feature

1. **Add method to OpenAI service**
   ```dart
   // lib/services/openai_service.dart
   Future<String> myAiFeature(String input) async {
     final response = await http.post(
       Uri.parse('${AppConstants.openAiApiUrl}/chat/completions'),
       headers: {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
       },
       body: jsonEncode({
         'model': 'gpt-4o',
         'messages': [
           {'role': 'user', 'content': 'Your prompt here: $input'}
         ],
       }),
     );

     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
       return data['choices'][0]['message']['content'];
     }

     throw Exception('API error');
   }
   ```

---

## 🔥 Firebase Setup

### Firestore Database Structure

```
users (collection)
  └── {userId} (document)
      ├── uid: string
      ├── email: string
      ├── displayName: string
      ├── questionnaireCompleted: boolean
      ├── preferences: map
      │   ├── dietaryRestrictions: array<string>
      │   ├── cuisinePreferences: array<string>
      │   ├── allergies: array<string>
      │   └── servingSize: number
      └── createdAt: timestamp

      fridgeItems (subcollection)
        └── {itemId} (document)
            ├── name: string
            ├── category: string
            ├── quantity: string
            ├── freshness: string
            ├── addedDate: timestamp
            ├── lastScanned: timestamp
            └── imageUrl: string

      recipes (subcollection)
        └── {recipeId} (document)
            ├── title: string
            ├── description: string
            ├── cuisine: string
            ├── prepTime: string
            ├── cookTime: string
            ├── servings: number
            ├── ingredients: array<string>
            ├── instructions: array<string>
            ├── usedIngredients: array<string>
            ├── savedAt: timestamp
            └── isFavorite: boolean
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Subcollections inherit parent rules
      match /fridgeItems/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /recipes/{recipeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /fridge_scans/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Deploying Rules

**Via Firebase Console** (Fastest):
1. Go to https://console.firebase.google.com/project/foodies-e099a
2. Navigate to Firestore → Rules or Storage → Rules
3. Paste the rules above
4. Click "Publish"

**Via Firebase CLI**:
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

---

## 🤖 OpenAI Integration

### Vision API (Fridge Scanning)

**Endpoint**: `https://api.openai.com/v1/chat/completions`
**Model**: `gpt-4o`

**Request Format**:
```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Analyze this fridge image and list all visible food items..."
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "https://firebase.storage.url/image.jpg"
          }
        }
      ]
    }
  ],
  "max_tokens": 1000
}
```

**Expected Response**:
```json
[
  {"name": "Milk", "category": "Dairy", "quantity": "1 gallon", "freshness": "fresh"},
  {"name": "Eggs", "category": "Dairy", "quantity": "1 dozen", "freshness": "fresh"}
]
```

### Chat API (Recipe Generation)

**Endpoint**: `https://api.openai.com/v1/chat/completions`
**Model**: `gpt-4o`

**Request Format**:
```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful chef assistant..."
    },
    {
      "role": "user",
      "content": "Create a recipe using these ingredients: milk, eggs, flour..."
    }
  ],
  "max_tokens": 1500
}
```

**Expected Response**:
```json
{
  "title": "French Toast",
  "description": "Classic breakfast dish",
  "cuisine": "French",
  "prepTime": "5 minutes",
  "cookTime": "10 minutes",
  "servings": 2,
  "ingredients": ["4 eggs", "1 cup milk", "8 slices bread"],
  "instructions": ["Beat eggs and milk", "Dip bread", "Cook until golden"],
  "usedIngredients": ["eggs", "milk"]
}
```

### API Costs (Estimated)

| Operation | Model | Cost per Call |
|-----------|-------|---------------|
| Fridge Scan | GPT-4o Vision | $0.01 - $0.03 |
| Recipe Generation | GPT-4o | $0.03 - $0.06 |

**Optimization Tips**:
- Resize images before upload (max 2048px)
- Cache recent AI responses
- Use shorter max_tokens for faster responses
- Consider GPT-3.5-turbo for non-critical features

---

## 📊 Database Schema

### UserModel
```dart
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool questionnaireCompleted;
  final List<String> dietaryRestrictions;
  final List<String> cuisinePreferences;
  final List<String> allergies;
  final int servingSize;
}
```

### FridgeItem
```dart
class FridgeItem {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final DateTime? expiryDate;
  final DateTime addedDate;
  final DateTime lastScanned;
  final String? imageUrl;
  final String freshness;
}
```

### Recipe
```dart
class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String cuisine;
  final DateTime savedAt;
  final bool isFavorite;
  final List<String> usedIngredients;
}
```

---

## 🔌 API Reference

### AuthService

```dart
// Sign up
Future<User?> signUp(String email, String password, String displayName)

// Sign in
Future<User?> signIn(String email, String password)

// Sign out
Future<void> signOut()

// Current user
User? get currentUser

// Auth state stream
Stream<User?> get authStateChanges
```

### FirestoreService

```dart
// User operations
Future<void> createUserProfile(User user, String displayName)
Future<UserModel?> getUserProfile(String uid)
Future<void> updateUserProfile(String uid, Map<String, dynamic> data)
Future<void> completeQuestionnaire(String uid, ...)

// Fridge operations
Stream<List<FridgeItem>> getFridgeItems(String uid)
Future<void> addFridgeItem(String uid, FridgeItem item)
Future<void> deleteFridgeItem(String uid, String itemId)
Future<void> clearFridge(String uid)

// Recipe operations
Stream<List<Recipe>> getSavedRecipes(String uid)
Future<void> saveRecipe(String uid, Recipe recipe)
Future<void> deleteRecipe(String uid, String recipeId)
```

### StorageService

```dart
// Mobile upload
Future<String> uploadFridgeImage(String uid, File imageFile)

// Web upload
Future<String> uploadFridgeImageWeb(String uid, XFile imageFile)

// Delete image
Future<void> deleteFridgeImage(String imageUrl)
```

### OpenAIService

```dart
// Analyze fridge image
Future<List<Map<String, String>>> analyzeFridgeImage(String imageUrl)

// Generate recipe
Future<Map<String, dynamic>?> generateRecipe(
  List<String> ingredients,
  List<String> dietaryRestrictions,
  List<String> cuisinePreferences,
  int servings,
)
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Firebase Connection Errors
**Error**: `Firebase initialization failed`

**Solution**:
- Verify `firebase_options.dart` exists
- Check internet connection
- Ensure Firebase project exists at console.firebase.google.com

#### 2. Storage Unauthorized Error
**Error**: `User is not authorized to perform the desired action`

**Solution**:
- Update Firebase Storage rules (see [Firebase Setup](#firebase-setup))
- Verify user is authenticated
- Check Storage bucket exists

#### 3. OpenAI API Errors
**Error**: `401 Unauthorized` or `429 Rate Limit`

**Solution**:
- Verify API key in `lib/utils/constants.dart`
- Check OpenAI account has credits
- Wait if rate-limited (or upgrade plan)

#### 4. Image.file on Web Error
**Error**: `Image.file is not supported on Flutter Web`

**Solution**: Already fixed! The app uses `kIsWeb` to detect platform and uses `Image.network()` on web.

#### 5. Build Errors
**Error**: Package errors after clone

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Debug Mode

Enable verbose logging:
```dart
// Temporarily enable print statements
// All services use print() for debugging
```

View logs:
```bash
# Flutter logs
flutter logs

# Firebase console
# Check Firestore/Storage tabs for errors
```

---

## 🤝 Contributing

### Team Workflow

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/my-feature
   ```

3. **Make changes and test**
   ```bash
   flutter analyze
   flutter test (if tests exist)
   ```

4. **Commit with clear messages**
   ```bash
   git add .
   git commit -m "Add: Recipe sharing feature"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/my-feature
   ```

### Code Style

- Use `flutter format .` before committing
- Follow Dart conventions
- Add comments for complex logic
- Keep functions small (<50 lines)

### Git Commit Conventions

```
Add: New feature
Fix: Bug fix
Update: Improve existing feature
Refactor: Code restructuring
Docs: Documentation updates
Style: UI/UX changes
```

---

## 📚 Additional Resources

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Docs](https://firebase.google.com/docs)
- [OpenAI API Docs](https://platform.openai.com/docs)

### Project Files
- `.claude/project-brief.md` - Complete project documentation
- `QUICKSTART.md` - Quick setup guide
- `IMPLEMENTATION_SUMMARY.md` - What's built and how

### Useful Commands

```bash
# Check Flutter environment
flutter doctor

# Run tests
flutter test

# Build for production
flutter build web
flutter build apk
flutter build ios

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build files
flutter clean
```

---

## 🔐 Security & API Keys

### ✅ This Repository is Safe to Push to GitHub!

**All sensitive data is handled securely:**

- ✅ **No API keys in code** - OpenAI API key is stored in Firebase Secrets Manager
- ✅ **No secrets in git** - All sensitive files are gitignored
- ✅ **Cloud Functions** - API calls are made server-side, not from client
- ✅ **Firebase Auth** - All Cloud Functions require authentication

### How It Works

```
Your Flutter App
    ↓ (authenticated request)
Firebase Cloud Functions
    ↓ (secure API call with secret key)
OpenAI API
    ↓
Response back to your app
```

**Your API key never leaves Firebase servers!**

### Setting Up API Keys

1. **OpenAI API Key**: Set as a Firebase Secret
   ```bash
   firebase functions:secrets:set OPENAI_API_KEY
   ```

2. **Firebase Config**: Already in `lib/firebase_options.dart` (safe to commit)

3. **Local Development**: Functions can be tested locally with emulator

See `DEPLOY_INSTRUCTIONS.md` for complete setup.

---

## 📄 License

MIT License - WashU Hackathon 2025

---

## 🎉 Acknowledgments

- **Flutter Team** - Amazing framework
- **Firebase** - Backend infrastructure
- **OpenAI** - AI capabilities
- **WashU Hackathon** - Opportunity to build

---

**Built with ❤️ for WashU Hackathon 2025**

For questions or issues, contact your team or check the documentation files.
