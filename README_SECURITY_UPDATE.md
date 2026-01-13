# 🔒 Security Update - API Key Protection

## What Changed?
API keys are no longer hardcoded. They're now loaded from environment variables.

## How to Run the App Now

### Option 1: Using dart-define (Recommended for Development)
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here --dart-define=ELEVENLABS_API_KEY=your_key_here
```

### Option 2: Using .env file
1. Create a `.env` file (copy from `.env.example`)
2. Add your keys:
   ```
   GEMINI_API_KEY=your_actual_key
   ELEVENLABS_API_KEY=your_actual_key
   ```
3. Run: `flutter run --dart-define-from-file=.env`

### Option 3: For Quick Testing (Temporary)
Manually edit `app_config.dart` with your keys for local testing ONLY.
**Never commit these changes!**

## For Production/Deployment

**⚠️ WARNING**: Never deploy a Flutter web app with API keys in client code!

### Secure Production Setup:
1. Create a backend API (Node.js/Python/Go)
2. Store keys as environment variables on your server
3. Flutter app calls YOUR backend
4. Your backend calls Gemini/ElevenLabs APIs

Example backend structure:
```
your-backend/
  ├── api/
  │   ├── gemini.js       # Proxies Gemini requests
  │   └── elevenlabs.js   # Proxies ElevenLabs requests
  └── .env                # API keys here (server-side)
```

## Files Changed:
- `lib/config/app_config.dart` - Now uses environment variables
- `.gitignore` - Added to ignore `.env` and secrets
- `.env.example` - Template for your `.env` file
- `SECURITY.md` - Security best practices

## Next Steps:
1. ✅ Revoke your leaked keys immediately
2. ✅ Generate new API keys
3. ✅ Set up environment variables
4. ✅ Test the app with new keys
5. ⚠️ Consider building a backend proxy for production
