# Buteyko World AI - AI-Powered Breathing App

A beautiful Flutter app that guides users through the Buteyko breathing method using AI-generated voice instructions with poetic, figurative language.

## Features

- **AI-Powered Voice Guidance**: Uses Google Cloud Text-to-Speech for calming, natural voice instructions
- **Beautiful Figurative Language**: Guides users through relaxation using metaphors like "warm honey flowing" and "balloons inflating"
- **Customizable Sessions**: Choose between 5-minute and 10-minute breathing sessions
- **Immersive UI**: Calming gradient backgrounds and breathing animations
- **Complete Buteyko Method**: Follows the specific posture and relaxation sequence you requested

## Setup Instructions

### 1. Prerequisites
- Flutter SDK installed
- VS Code with Flutter extension
- Google Cloud account (for Text-to-Speech API)

### 2. Google Cloud Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the "Cloud Text-to-Speech API"
4. Create credentials (API key)
5. Copy your API key

### 3. Configure the App
1. Open `lib/config/app_config.dart`
2. Replace `YOUR_GOOGLE_CLOUD_API_KEY_HERE` with your actual API key:
   ```dart
   static const String googleCloudApiKey = 'your-actual-api-key-here';
   ```

### 4. Run the App
```bash
# Install dependencies
flutter pub get

# Run on your device/emulator
flutter run
```

## How to Use

1. **Welcome Screen**: Tap the big "Start Buteyko" button
2. **Choose Duration**: Select 5 or 10 minutes for your session
3. **Prepare**: Sit in a firm chair, on the edge, with good posture
4. **Follow Guidance**: The AI will guide you through:
   - Posture setup ("Christmas tree ornament" metaphor)
   - Progressive body relaxation with figurative language
   - Deep breathing with healing imagery
5. **Complete**: Session ends automatically with a completion message

## App Structure

```
lib/
├── config/
│   └── app_config.dart          # Configuration and API key
├── services/
│   └── tts_service.dart         # Google Cloud TTS integration
├── screens/
│   ├── welcome_screen.dart      # Main screen with big button
│   ├── duration_selection_screen.dart  # Choose 5 or 10 minutes
│   └── exercise_screen.dart     # Guided session with timer
└── main.dart                    # App entry point
```

## Voice Guidance Script

The app includes carefully crafted figurative language such as:
- "Imagine you are a Christmas tree ornament, tied up by the top of your head"
- "Feel warm honey melting from the top of your head"
- "Your wrists inflate like gentle balloons, becoming heavy and warm"
- "Warm rain is rolling down, relaxing every muscle it touches"

## Customization

You can modify the guidance script in `lib/services/tts_service.dart` in the `ButeykoGuidanceScript.getGuidanceSteps()` method.

## Benefits of Buteyko Breathing

- Reduces anxiety and stress
- Helps with asthma and allergies
- Improves sleep quality
- Reduces panic attacks
- Enhances focus and mental clarity
- Promotes overall health and wellbeing

## Development Notes

- Built with Flutter for cross-platform compatibility
- Uses Google Cloud Text-to-Speech for natural voice generation
- Includes fallback text display if TTS fails
- Features smooth animations and calming color scheme
- Implements proper session timing and controls

## Support

If you have any issues:
1. Ensure your Google Cloud API key is correctly configured
2. Check that the Text-to-Speech API is enabled in your Google Cloud project
3. Verify internet connection for TTS functionality

Enjoy your journey to better breathing and improved health! 🌬️✨
