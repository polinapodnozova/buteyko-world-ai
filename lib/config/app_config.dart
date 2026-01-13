class AppConfig {
  // Backend API URL - This is your secure proxy server
  // Change this to your deployed backend URL
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3000', // For local development
  );
  
  // Production backend URL (update after deploying backend)
  static const String productionBackendUrl = 'https://your-backend-url.vercel.app';
  
  // Use production URL if not in debug mode
  static String get apiBaseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? productionBackendUrl : backendUrl;
  }
  
  // App Information
  static const String appName = 'Buteyko World AI';
  static const String appVersion = '1.0.0';
  
  // ElevenLabs TTS Configuration for beautiful voice
  // Available voices for users to choose from:
  static const Map<String, Map<String, String>> availableVoices = {
    'sarah': {
      'id': 'EXAVITQu4vr4xnSDxMaL',
      'name': 'Sarah',
      'description': 'Soft, gentle American female',
    },
    'adam': {
      'id': 'pNInz6obpgDQGcFmaJgB',
      'name': 'Adam',
      'description': 'Calm, soothing American male',
    },
  };
  
  // Default voice (will be overridden by user preference)
  static const String defaultVoiceKey = 'sarah';
  static const String elevenLabsModel = 'eleven_turbo_v2_5'; // New free tier model
  static const double elevenLabsStability = 0.8; // Voice stability
  static const double elevenLabsSimilarity = 0.8; // Voice similarity
  
  // Session durations in minutes
  static const List<int> availableDurations = [5, 10];
  
  // UI Colors
  static const int primaryBlue = 0xFF2E86AB;
  static const int secondaryMint = 0xFFA23B72;
  static const int backgroundGradientTop = 0xFF87CEEB;
  static const int backgroundGradientBottom = 0xFFB6E5D8;
}