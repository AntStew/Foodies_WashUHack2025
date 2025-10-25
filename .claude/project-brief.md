# Foodies - WashU Hackathon 2025

## Project Overview
A Flutter app that helps users manage their fridge inventory and generate recipes based on available ingredients using AI.

## Firebase Configuration
- **Project ID**: foodies-e099a
- **Platform Support**: Web, Android, iOS, macOS, Windows
- **Firebase Services**:
  - Firebase Core ✓
  - Firebase Analytics ✓
  - Firebase Auth (needed)
  - Cloud Firestore (needed)

## Key Features

### 1. Authentication Flow
- **New Users**: Login/Signup → Questionnaire → Home Page
- **Returning Users**: Login → Home Page
- Store user preferences and questionnaire responses in Firestore

### 2. Home Page Components
- **Fridge Inventory List**: Display all items currently in user's fridge
- **Rescan Fridge Button**: Trigger new fridge analysis
- **Generate Recipes Button**: Create recipes based on available ingredients
- **Saved Recipes Button**: View previously saved recipes

### 3. Fridge Analysis
- Use **OpenAI Vision API** (GPT-4 Vision) to analyze fridge photos
- Extract ingredients, quantities, and freshness
- Store results in Firestore

### 4. Recipe Generation
- Use **OpenAI Chat API** (GPT-4) to generate recipes
- Consider: available ingredients, dietary restrictions, cuisine preferences
- Allow users to save favorite recipes

## Tech Stack

### Frontend
- **Framework**: Flutter
- **State Management**: Provider or Riverpod (TBD)
- **UI Components**: Material Design

### Backend
- **BaaS**: Firebase
  - Authentication
  - Cloud Firestore (database)
  - Cloud Storage (fridge images)
  - Cloud Functions (optional, for serverless processing)

### AI/ML
- **OpenAI API**:
  - GPT-4 Vision (fridge scanning)
  - GPT-4 (recipe generation)
  - API Key: (store in environment variables)

## Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init
├── firebase_options.dart              # Firebase configuration
│
├── models/                            # Data models
│   ├── user_model.dart               # User profile data
│   ├── questionnaire_model.dart      # Questionnaire responses
│   ├── fridge_item_model.dart        # Individual fridge item
│   ├── recipe_model.dart             # Recipe data structure
│   └── fridge_scan_model.dart        # Scan metadata
│
├── services/                          # Business logic & API calls
│   ├── auth_service.dart             # Firebase Authentication
│   ├── firestore_service.dart        # Firestore CRUD operations
│   ├── storage_service.dart          # Firebase Storage (images)
│   ├── openai_service.dart           # OpenAI API integration
│   │   ├── vision_service.dart       # Fridge image analysis
│   │   └── chat_service.dart         # Recipe generation
│   └── user_service.dart             # User data management
│
├── screens/                           # UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── questionnaire_screen.dart
│   │
│   ├── home/
│   │   ├── home_screen.dart          # Main home page
│   │   └── widgets/
│   │       ├── fridge_item_card.dart
│   │       └── action_button.dart
│   │
│   ├── fridge/
│   │   ├── fridge_scan_screen.dart   # Camera/upload interface
│   │   ├── fridge_list_screen.dart   # Full inventory view
│   │   └── fridge_item_detail.dart   # Edit/view item details
│   │
│   └── recipes/
│       ├── recipe_generate_screen.dart
│       ├── recipe_detail_screen.dart
│       └── saved_recipes_screen.dart
│
├── widgets/                           # Reusable widgets
│   ├── custom_button.dart
│   ├── loading_indicator.dart
│   ├── error_dialog.dart
│   └── custom_text_field.dart
│
├── providers/                         # State management
│   ├── auth_provider.dart
│   ├── fridge_provider.dart
│   ├── recipe_provider.dart
│   └── user_provider.dart
│
├── utils/                             # Utilities & helpers
│   ├── constants.dart                # App constants
│   ├── validators.dart               # Form validation
│   ├── date_helpers.dart             # Date formatting
│   └── api_keys.dart                 # API key management (gitignored)
│
└── routes/                            # Navigation
    └── app_routes.dart               # Route definitions
```

## Database Schema (Firestore)

### Collections

#### `users/{userId}`
```dart
{
  'uid': String,
  'email': String,
  'displayName': String,
  'photoURL': String?,
  'createdAt': Timestamp,
  'questionnaireCompleted': bool,
  'preferences': {
    'dietaryRestrictions': List<String>, // ['vegetarian', 'gluten-free', etc.]
    'cuisinePreferences': List<String>,  // ['italian', 'mexican', etc.]
    'allergies': List<String>,
    'servingSize': int,
  }
}
```

#### `users/{userId}/fridgeItems/{itemId}`
```dart
{
  'itemId': String,
  'name': String,
  'category': String,              // 'dairy', 'produce', 'meat', etc.
  'quantity': String,              // '2 lbs', '1 gallon', etc.
  'expiryDate': Timestamp?,
  'addedDate': Timestamp,
  'lastScanned': Timestamp,
  'imageUrl': String?,
  'freshness': String?,            // 'fresh', 'moderate', 'expiring'
}
```

#### `users/{userId}/recipes/{recipeId}`
```dart
{
  'recipeId': String,
  'title': String,
  'description': String,
  'ingredients': List<String>,
  'instructions': List<String>,
  'prepTime': String,
  'cookTime': String,
  'servings': int,
  'cuisine': String,
  'savedAt': Timestamp,
  'isFavorite': bool,
  'usedIngredients': List<String>, // Ingredients from their fridge
  'generatedBy': String,           // 'openai'
}
```

#### `users/{userId}/scans/{scanId}`
```dart
{
  'scanId': String,
  'imageUrl': String,
  'scannedAt': Timestamp,
  'itemsDetected': int,
  'rawResponse': String,           // Raw OpenAI response
  'status': String,                // 'processing', 'completed', 'failed'
}
```

## OpenAI Integration

### Fridge Scanning Flow
1. User takes/uploads fridge photo
2. Upload image to Firebase Storage
3. Send image URL to OpenAI Vision API
4. Parse response to extract ingredients
5. Create/update fridge items in Firestore
6. Display updated inventory

### Recipe Generation Flow
1. Fetch all fridge items for user
2. Prepare prompt with ingredients + preferences
3. Call OpenAI Chat API
4. Parse recipe response
5. Display recipe
6. Option to save to Firestore

## Required Dependencies

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3           # Add this
  cloud_firestore: ^5.5.0         # Add this
  firebase_storage: ^12.3.6       # Add this

  # State Management
  provider: ^6.1.2                # Add this (or riverpod)

  # HTTP & API
  http: ^1.2.0                    # Add this

  # Image handling
  image_picker: ^1.0.7            # Add this
  cached_network_image: ^3.3.1   # Add this

  # UI
  flutter_svg: ^2.0.10            # Add this (optional)
  intl: ^0.19.0                   # Add this (date formatting)

  # Other
  shared_preferences: ^2.2.2      # Add this (local storage)
```

## Implementation Phases

### Phase 1: Authentication ✓ (Setup Complete)
- [x] Firebase initialization
- [ ] Add firebase_auth dependency
- [ ] Create auth_service.dart
- [ ] Build login_screen.dart
- [ ] Build signup_screen.dart
- [ ] Build questionnaire_screen.dart
- [ ] Set up navigation flow

### Phase 2: Database Setup
- [ ] Add cloud_firestore dependency
- [ ] Create Firestore service
- [ ] Define data models
- [ ] Set up Firestore security rules
- [ ] Create user profile on signup

### Phase 3: Fridge Management
- [ ] Add image_picker dependency
- [ ] Create fridge scan screen (camera/upload)
- [ ] Set up Firebase Storage
- [ ] Integrate OpenAI Vision API
- [ ] Parse and store fridge items
- [ ] Build fridge inventory UI

### Phase 4: Recipe Generation
- [ ] Integrate OpenAI Chat API
- [ ] Build recipe generation logic
- [ ] Create recipe display UI
- [ ] Implement save recipe functionality
- [ ] Build saved recipes screen

### Phase 5: Polish & Testing
- [ ] Error handling
- [ ] Loading states
- [ ] Offline support
- [ ] UI/UX improvements
- [ ] Testing

## Environment Variables

Create `.env` file (add to .gitignore):
```
OPENAI_API_KEY=your_api_key_here
```

## Team Collaboration Notes

- **Git Strategy**: Feature branches, merge to main
- **Code Style**: Follow Flutter/Dart conventions
- **Testing**: Focus on core flows (auth, scanning, recipes)
- **API Quotas**: Monitor OpenAI API usage (cost management)

## API Cost Estimates (OpenAI)

- **GPT-4 Vision**: ~$0.01-0.03 per image
- **GPT-4**: ~$0.03-0.06 per recipe generation
- **Budget for hackathon**: Set daily limits

## Security Considerations

1. **API Keys**: Never commit to Git
2. **Firestore Rules**: Restrict to authenticated users only
3. **Storage Rules**: Users can only access their own images
4. **Rate Limiting**: Implement client-side throttling

## Next Immediate Steps

1. Add required Firebase dependencies (auth, firestore, storage)
2. Create models folder and define data models
3. Set up authentication service
4. Build login/signup screens
5. Create questionnaire screen
6. Set up OpenAI API service structure

---

**Last Updated**: 2025-10-25
**Team Members**: [Add names here]
**Hackathon**: WashU Hack 2025
