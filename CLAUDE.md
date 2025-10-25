# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Foodies is a Flutter-based smart fridge management app built for WashU Hackathon 2025. It uses OpenAI Vision API (via Firebase Cloud Functions) to identify food items from fridge photos and generates personalized recipes based on available ingredients and user preferences.

## Common Development Commands

### Flutter Development
```bash
# Get dependencies
flutter pub get

# Run the app (web)
flutter run -d chrome

# Run the app (Android emulator)
flutter run -d android

# Run the app (iOS simulator - Mac only)
flutter run -d ios

# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build artifacts
flutter clean
```

### Firebase Cloud Functions
```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Set OpenAI API key as a secret (required for AI features)
firebase functions:secrets:set OPENAI_API_KEY

# Set Pexels API key as a secret (optional, for recipe images)
firebase functions:secrets:set PEXELS_API_KEY

# Deploy functions
firebase deploy --only functions

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# View function logs
firebase functions:log
```

## Architecture Overview

### Three-Layer Architecture

1. **Presentation Layer** (`lib/screens/`)
   - UI components and widgets
   - User interactions and navigation
   - Uses StreamBuilder for real-time Firestore data

2. **Business Logic Layer** (`lib/services/`)
   - Service classes that handle business logic
   - Firebase integrations (Auth, Firestore, Storage)
   - OpenAI API calls via Cloud Functions

3. **Data Layer** (`lib/models/`)
   - Plain Dart objects (PODOs)
   - Firestore serialization/deserialization
   - Data transformation methods

### Key Services

- **AuthService** (`lib/services/auth_service.dart`): Firebase Authentication wrapper for signup, signin, and signout
- **FirestoreService** (`lib/services/firestore_service.dart`): All Firestore CRUD operations for users, fridge items, and recipes
- **OpenAIService** (`lib/services/openai_service.dart`): Calls Firebase Cloud Functions that interact with OpenAI APIs
- **StorageService** (`lib/services/storage_service.dart`): Uploads fridge images to Firebase Storage

### Data Flow

#### Fridge Scanning Flow
```
User captures image → Upload to Firebase Storage → Get image URL →
Call Cloud Function (analyzeFridgeImage) → OpenAI Vision API analyzes image →
Parse JSON response → Save items to Firestore → Real-time update in HomeScreen
```

#### Recipe Generation Flow
```
User requests recipe → Fetch fridge items + user preferences →
Call Cloud Function (generateRecipe) → OpenAI Chat API generates recipe →
Optionally fetch recipe image from Pexels → Display recipe →
User can save to Firestore
```

### Firestore Data Structure

```
users/{userId}
  ├── uid, email, displayName, questionnaireCompleted
  ├── preferences: {dietaryRestrictions[], cuisinePreferences[], allergies[], servingSize}
  ├── fridgeItems/{itemId}
  │   └── name, category, quantity, freshness, addedDate, lastScanned, imageUrl
  └── recipes/{recipeId}
      └── title, description, cuisine, prepTime, cookTime, servings,
          ingredients[], instructions[], usedIngredients[], savedAt, isFavorite, imageUrl
```

### Navigation Structure

- **InitialScreen** (`lib/main.dart`): Auth check → routes to login or home
- **LoginScreen** → **SignupScreen** → **QuestionnaireScreen** (first-time users only)
- **HomeScreen**: Main dashboard with fridge items (uses real-time streams)
- **FridgeScanScreen**: Camera/gallery + AI analysis
- **RecipeGenerateScreen**: AI recipe generation from fridge items
- **SavedRecipesScreen**: List of user's saved recipes
- **RecipeDetailScreen**: Full recipe view with instructions

All routes defined in `lib/routes/app_routes.dart`.

## Important Implementation Details

### Real-Time Data Synchronization

All fridge items and recipes use Firestore **streams** for real-time updates:

```dart
StreamBuilder<List<FridgeItem>>(
  stream: firestoreService.getFridgeItems(userId),
  builder: (context, snapshot) {
    // UI automatically rebuilds when data changes in Firestore
  }
)
```

### Cloud Functions Security

**CRITICAL**: OpenAI API keys are stored as Firebase Secrets, NOT in code. The app never contains API keys.

- Client calls `FirebaseFunctions.httpsCallable('analyzeFridgeImage')`
- Cloud Function verifies authentication (`request.auth`)
- Cloud Function uses secret API key to call OpenAI
- Response returned to client

Both Cloud Functions (`analyzeFridgeImage` and `generateRecipe`) require authentication and enforce user security.

### Models and Firestore Serialization

All models (`UserModel`, `FridgeItem`, `Recipe`) must have:
- `toMap()`: Convert to Firestore-compatible Map
- `fromMap(String id, Map<String, dynamic> map)`: Factory constructor from Firestore data
- Proper DateTime <-> Timestamp conversion

### Platform-Specific Code

The app supports web, iOS, and Android. Some screens handle platform differences:
- Web uses `Image.network()` instead of `Image.file()`
- Image picker handles platform-specific file types (File vs XFile)
- Storage service has separate methods for mobile (`uploadFridgeImage`) and web (`uploadFridgeImageWeb`)

## Firebase Configuration

### Required Firebase Products
- **Firebase Authentication**: Email/password auth
- **Cloud Firestore**: NoSQL database for users, fridge items, recipes
- **Firebase Storage**: Image storage for fridge scans
- **Cloud Functions**: Serverless functions for OpenAI API integration

### Firebase Secrets (Cloud Functions)
- `OPENAI_API_KEY`: Required for fridge analysis and recipe generation
- `PEXELS_API_KEY`: Optional, for fetching recipe images (has Unsplash fallback)

Set secrets with: `firebase functions:secrets:set SECRET_NAME`

### Security Rules

Firestore and Storage rules ensure users can only access their own data. User ID from Firebase Auth is verified against document paths.

## Code Style & Conventions

### State Management
- Minimal use of state management (some Provider, mostly StatefulWidget)
- Real-time data via StreamBuilder (no manual state updates needed)
- Services instantiated directly in widgets (e.g., `final _authService = AuthService()`)

### Error Handling
- Services use try-catch and rethrow exceptions
- Logging via custom `AppLogger` (`lib/utils/logger.dart`)
- UI shows user-friendly error messages in dialogs or snackbars

### Widget Organization
- Large screens broken into smaller widgets (e.g., `home_screen.dart` uses `widgets/` subfolder)
- Reusable components: `EmptyStateWidget`, `NoResultsWidget`, `CategorySectionWidget`, etc.
- Widgets follow Material Design 3 principles

### Naming Conventions
- Services: `*_service.dart`
- Models: `*_model.dart`
- Screens: `*_screen.dart`
- Private fields/methods: prefix with `_`

## AI Integration Notes

### OpenAI Vision API (Fridge Analysis)
- Model: `gpt-4o`
- Input: Firebase Storage image URL
- Output: JSON array of items with `{name, category, quantity, freshness}`
- Prompt asks for specific categories: Dairy, Produce, Meat, Seafood, Frozen, Beverages, Condiments, Other
- Response parsed with regex to extract JSON

### OpenAI Chat API (Recipe Generation)
- Model: `gpt-4o`
- Input: Ingredients list + dietary restrictions + cuisine preferences + servings
- Output: JSON object with `{title, description, cuisine, prepTime, cookTime, servings, ingredients[], instructions[], usedIngredients[]}`
- After generation, Pexels API searches for recipe image (with Unsplash fallback)

### Cost Optimization
- Images can be resized before upload (not currently implemented)
- `max_tokens` limits set on API calls (1000 for vision, 1500 for chat)
- Consider caching AI responses for identical requests (not currently implemented)

## Common Development Tasks

### Adding a New Fridge Item Field
1. Update `FridgeItem` model in `lib/models/fridge_item_model.dart`
2. Update `toMap()` and `fromMap()` methods
3. Modify UI in `lib/screens/home/widgets/fridge_item_widget.dart`
4. Update Cloud Function prompt if field should be AI-detected

### Adding a New User Preference
1. Update `UserModel` in `lib/models/user_model.dart`
2. Update questionnaire UI in `lib/screens/auth/questionnaire_screen.dart`
3. Update `completeQuestionnaire()` in `lib/services/firestore_service.dart`
4. Include preference in recipe generation prompt

### Adding a New Screen
1. Create screen in `lib/screens/` with appropriate subfolder
2. Add route constant in `lib/routes/app_routes.dart`
3. Add route mapping in `AppRoutes.routes`
4. Navigate with `Navigator.pushNamed(context, AppRoutes.myScreen)`

### Modifying AI Prompts
1. Edit Cloud Functions in `functions/index.js`
2. Update prompt text in relevant function (`analyzeFridgeImage` or `generateRecipe`)
3. Redeploy: `firebase deploy --only functions`
4. Test with actual API calls (changes affect production immediately)

## Testing Notes

- No formal test suite currently exists
- Manual testing flow:
  1. Sign up with test account
  2. Complete questionnaire
  3. Upload test fridge image (use high-quality, well-lit photos)
  4. Verify items detected correctly
  5. Generate recipe and verify it uses fridge items
  6. Test save/delete functionality

## Known Limitations

- No offline support (requires internet for all operations)
- No image compression before upload (large images increase costs)
- No caching of AI responses
- Recipe images depend on external APIs (Pexels/Unsplash) which may fail
- No pagination for large fridge inventories or recipe collections
- Search only filters by item name, not category or freshness

## Dependencies

Key packages:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`: Firebase integration
- `provider`: State management (minimal usage)
- `image_picker`: Camera and gallery access
- `cached_network_image`: Efficient image loading
- `intl`: Date formatting
- `logger`: Logging utilities

Firebase project ID: `foodies-e099a` (visible in `firebase_options.dart`)
