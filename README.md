# Cardio Tracker

A Flutter application for tracking and managing blood pressure readings with cloud synchronization capabilities using Cloudflare KV, built using Clean Architecture principles.

## Features

### Core Functionality
- **Blood Pressure Tracking**: Record systolic, diastolic, and heart rate measurements
- **Categorization**: Automatic classification of readings (Normal, Elevated, Stage 1/2 Hypertension, Crisis)
- **Visual Analytics**: Interactive charts and graphs to visualize trends over time
- **Data Export**: Export readings to CSV for sharing with healthcare providers
- **Medication Reminders**: Set up reminders for blood pressure medications

### Cloud Synchronization (NEW!)
- **Manual Sync**: User-controlled synchronization with Cloudflare KV
- **Cross-Device Access**: Access your data from multiple devices
- **Secure Storage**: Encrypted credential storage using Flutter Secure Storage
- **Conflict Resolution**: Automatic handling of sync conflicts using last-write-wins
- **Offline First**: Works offline with optional cloud backup

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- For Android: Android SDK with API level 21+
- For iOS: Xcode 14.0+
- For Cloud Sync: Cloudflare account with KV namespace

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/cardio_tracker.git
cd cardio_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For development
flutter run

# For release build
flutter build apk    # Android
flutter build ios    # iOS
flutter build macos  # macOS
```

## Cloud Sync Setup

The app now supports syncing your blood pressure readings with Cloudflare KV for backup and multi-device access.

### Step 1: Create Cloudflare KV Namespace

1. Log in to your [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Navigate to **Workers & Pages** → **KV**
3. Click **"Create a namespace"**
4. Enter a name (e.g., `cardio-tracker-sync`)
5. Click **"Add"**
6. Copy the **Namespace ID** for later use

### Step 2: Generate API Token

1. In Cloudflare Dashboard, go to **My Profile** → **API Tokens**
2. Click **"Create Token"**
3. Use the **"Custom token"** template
4. Configure permissions:
   - **Account**: `Cloudflare KV:Edit`
   - **Zone Resources**: `All zones` or your specific account
5. Click **"Continue to summary"** → **"Create Token"**
6. Copy the generated token (save it securely)

### Step 3: Find Your Account ID

Your Account ID can be found in:
- The Cloudflare Dashboard URL when viewing your account
- Right sidebar of the dashboard under "Account ID"

### Step 4: Configure in App

1. Open Cardio Tracker app
2. Go to **Settings** → **Cloudflare Sync**
3. Enter your credentials:
   - **Account ID**: Your Cloudflare account ID
   - **Namespace ID**: From Step 1
   - **API Token**: From Step 2
4. Tap **"Save"**

### Step 5: Sync Your Data

1. After configuration, tap **"Sync Now"**
2. The app will:
   - Upload your local readings to Cloudflare
   - Download any readings from other devices
   - Resolve conflicts automatically
3. Review the sync results displayed

## Sync Behavior

### How Sync Works
- **Manual Only**: Sync only happens when you tap the sync button
- **Bidirectional**: Changes flow both ways between devices
- **Last-Write-Wins**: When conflicts occur, the most recently modified version wins
- **Soft Deletes**: Deleted items are marked and synced, then cleaned up locally

### Privacy & Security
- All data is transmitted over HTTPS
- API tokens are stored securely on your device
- Only you have access to your data with your API token
- Data is encrypted at rest in Cloudflare KV

### Troubleshooting

**"Not configured" error**
- Verify all three fields are filled correctly
- Check that your API token hasn't expired

**"Invalid API token" error**
- Ensure the token has `Cloudflare KV:Edit` permission
- Regenerate the token if necessary

**Sync fails partially**
- Check your internet connection
- Try syncing again after a few minutes
- Large datasets may take longer to sync initially

**"Namespace not found"**
- Verify the Namespace ID is correct
- Ensure the namespace exists in your Cloudflare account

## Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point & dependency injection setup
├── domain/                   # Business logic (core)
│   ├── entities/             # Domain entities
│   │   ├── blood_pressure_reading.dart
│   │   └── user_settings.dart
│   ├── value_objects/        # Value objects
│   │   └── blood_pressure_category.dart
│   ├── repositories/         # Repository interfaces
│   │   ├── blood_pressure_repository.dart
│   │   └── user_settings_repository.dart
│   └── failures/             # Error handling
│       └── failures.dart
├── application/              # Use cases (application layer)
│   └── use_cases/
│       ├── get_all_readings.dart
│       ├── add_reading.dart
│       ├── update_reading.dart
│       ├── delete_reading.dart
│       └── get_reading_statistics.dart
├── infrastructure/           # External dependencies
│   ├── data_sources/         # Data sources
│   │   └── local_database_source.dart
│   ├── repositories/         # Repository implementations
│   │   ├── blood_pressure_repository_impl.dart
│   │   └── user_settings_repository_impl.dart
│   ├── services/             # External services
│   │   ├── cloudflare_kv_service.dart
│   │   └── manual_sync_service.dart
│   └── mappers/              # Data mapping
│       └── blood_pressure_reading_mapper.dart
├── presentation/            # UI layer
│   ├── providers/            # State management (Provider pattern)
│   │   ├── blood_pressure_provider.dart
│   │   ├── settings_provider.dart
│   │   └── theme_provider.dart
│   └── screens/              # UI screens
│       ├── dashboard_screen.dart
│       ├── add_reading_screen.dart
│       ├── settings_screen.dart
│       └── cloudflare_settings_screen.dart
├── core/                     # Shared core utilities
│   ├── injection/            # Dependency injection
│   │   ├── injection.dart
│   │   └── injection_module.dart
│   ├── errors/               # Error types
│   │   └── failures.dart
│   └── utils/                # Utility functions
├── widgets/                  # Reusable UI components
│   ├── charts/
│   └── clinical_scatter_plot.dart
└── theme/                    # App theming
    ├── app_theme.dart
    └── app_colors.dart
```

### Architecture Benefits

- **Separation of Concerns**: Each layer has specific responsibilities
- **Testability**: Business logic is isolated from UI and external dependencies
- **Maintainability**: Easy to locate and modify specific functionality
- **Scalability**: Easy to add new features without affecting existing code
- **Dependency Inversion**: High-level modules don't depend on low-level modules

### Key Design Patterns

- **Repository Pattern**: Abstracts data access logic
- **Use Case Pattern**: Encapsulates specific application business rules
- **Dependency Injection**: Manages dependencies and improves testability
- **Provider Pattern**: State management for Flutter UI
- **Mapper Pattern**: Converts between data models and domain entities

### Key Dependencies

#### Core Architecture
- `dartz`: Functional programming with Either type for error handling
- `injectable`: Automatic dependency injection
- `get_it`: Service locator for dependency injection
- `equatable`: Value equality for entities

#### Database & Storage
- `sqflite`: SQLite database for local storage
- `path_provider`: Access to file system paths
- `flutter_secure_storage`: Secure credential storage

#### UI & State Management
- `provider`: State management using Provider pattern
- `fl_chart`: Data visualization and charts
- `flutter/material.dart`: Material Design components

#### Networking
- `http`: HTTP client for Cloudflare API
- `json_annotation`: JSON serialization annotations

#### Utilities
- `share_plus`: File sharing
- `csv`: CSV export functionality
- `freezed`: Code generation for immutable classes

### Running Tests

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run specific test files
flutter test test/domain/entities/
flutter test test/application/use_cases/
flutter test test/infrastructure/repositories/

# Generate test coverage report
flutter test --coverage
lcov --remove coverage/lcov.info '**/*.g.dart' '**/*.freezed.dart' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
```

### Code Generation

This project uses code generation for dependency injection and immutable classes:

```bash
# Generate dependency injection code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch for changes during development
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

### v2.0.0 (Latest) - Clean Architecture Refactor
- 🏗️ Complete refactoring to Clean Architecture
- 🔧 Implemented dependency injection with Injectable
- ✅ Enhanced error handling with Either types
- 🎯 Added use cases for all business operations
- 🧪 Improved testability and maintainability
- 🔒 Fixed type casting issues in Cloudflare sync
- 📦 Added Value Objects for better domain modeling
- 🛡️ Safe type casting for backward compatibility

### v1.1.0
- ✨ Added Cloudflare KV synchronization
- 🔒 Secure credential storage
- 📊 Improved sync status indicators
- 📱 Enhanced settings UI
- 📝 Comprehensive sync documentation

### v1.0.0
- 🎉 Initial release
- 📈 Blood pressure tracking
- 📊 Visual analytics
- 📤 CSV export
- ⏰ Medication reminders

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- For app issues: Open an issue on GitHub
- For Cloudflare KV issues: Check the [Cloudflare documentation](https://developers.cloudflare.com/workers/runtime-apis/kv/)
- For Flutter issues: Check the [Flutter documentation](https://docs.flutter.dev/)

## Acknowledgments

- Flutter team for the amazing framework
- Cloudflare for providing KV storage
- Medical professionals who provided input on the categorization system
- The open-source community for various packages used in this project
