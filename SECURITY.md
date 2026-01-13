# Security Guide

## API Key Management

### DO NOT:
- ❌ Hardcode API keys in source code
- ❌ Commit API keys to git
- ❌ Share API keys in screenshots or documentation
- ❌ Store keys in client-side code for production

### DO:
- ✅ Use environment variables for keys
- ✅ Keep `.env` in `.gitignore`
- ✅ Use separate keys for development/production
- ✅ Rotate keys regularly
- ✅ Use backend proxy for production apps

## Setup

### Development:
1. Copy `.env.example` to `.env`
2. Fill in your API keys in `.env`
3. Run with: `flutter run --dart-define-from-file=.env`

### Production:
For a production Flutter web app, you should:
1. **Never expose API keys in client code**
2. Create a backend API proxy (Node.js/Python/etc.)
3. Store keys as server environment variables
4. Have Flutter app call your backend, not APIs directly

## Key Rotation Checklist
- [ ] Revoke old key from provider dashboard
- [ ] Generate new key
- [ ] Update `.env` file (DO NOT commit)
- [ ] Test app functionality
- [ ] Update production environment variables
- [ ] Deploy updated version

## If Keys Are Leaked:
1. **IMMEDIATELY** revoke keys from provider
2. Generate new keys
3. Clean git history: `git filter-branch` or use BFG Repo Cleaner
4. Force push cleaned history
5. Notify all collaborators
6. Update all deployments
