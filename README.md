# Cardio Tracker

A Flutter application for tracking and managing blood pressure readings with cloud synchronization capabilities using Cloudflare KV.

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

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── blood_pressure_reading.dart
│   └── user_settings.dart
├── services/                 # Business logic
│   ├── database_service.dart      # Local SQLite database
│   ├── cloudflare_kv_service.dart # Cloudflare KV client
│   ├── manual_sync_service.dart   # Sync orchestration
│   └── csv_export_service.dart    # Data export
├── screens/                  # UI screens
│   ├── dashboard_screen.dart      # Main screen
│   ├── add_reading_screen.dart    # Add new reading
│   ├── settings_screen.dart       # App settings
│   └── cloudflare_settings_screen.dart # Cloud sync configuration
├── providers/                # State management
│   └── blood_pressure_provider.dart
├── widgets/                  # Reusable UI components
│   └── clinical_scatter_plot.dart
└── utils/                    # Utilities
```

### Key Dependencies

- `sqflite`: SQLite database for local storage
- `provider`: State management
- `fl_chart`: Data visualization
- `flutter_secure_storage`: Secure credential storage
- `http`: HTTP client for Cloudflare API
- `share_plus`: File sharing
- `csv`: CSV export functionality

### Running Tests

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

### v1.1.0 (Latest)
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
