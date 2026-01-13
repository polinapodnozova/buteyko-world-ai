# 🚀 Deployment Guide - Secure Backend Setup

## Overview
Your Flutter app now calls a secure backend API instead of exposing keys in client code. This is the proper production setup!

## Step-by-Step Deployment

### Step 1: Deploy Backend to Vercel (FREE & Easy)

1. **Install Vercel CLI** (if not already installed):
   ```bash
   npm install -g vercel
   ```

2. **Navigate to backend folder**:
   ```bash
   cd backend
   ```

3. **Create `.env` file** with your NEW API keys:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your keys:
   ```
   GEMINI_API_KEY=your_new_gemini_key_here
   ELEVENLABS_API_KEY=your_new_elevenlabs_key_here
   ALLOWED_ORIGINS=https://polinapodnozova.github.io
   ```

4. **Install dependencies**:
   ```bash
   npm install
   ```

5. **Test locally** (optional):
   ```bash
   npm start
   ```
   Visit http://localhost:3000/health

6. **Deploy to Vercel**:
   ```bash
   vercel login
   vercel
   ```
   
   Follow prompts:
   - Set up and deploy? **Yes**
   - Which scope? Choose your account
   - Link to existing project? **No**
   - Project name? **buteyko-world-backend**
   - Directory? **./backend** (or just press Enter if already in backend/)
   - Override settings? **No**

7. **Add environment variables in Vercel**:
   After deployment, go to: https://vercel.com/dashboard
   - Select your project (buteyko-world-backend)
   - Go to Settings → Environment Variables
   - Add:
     - `GEMINI_API_KEY` = your new Gemini key
     - `ELEVENLABS_API_KEY` = your new ElevenLabs key
     - `ALLOWED_ORIGINS` = https://polinapodnozova.github.io
     - `NODE_ENV` = production

8. **Redeploy** to apply environment variables:
   ```bash
   vercel --prod
   ```

9. **Copy your backend URL** (looks like: https://buteyko-world-backend-abc123.vercel.app)

### Step 2: Update Flutter App

1. **Edit `lib/config/app_config.dart`**:
   ```dart
   static const String productionBackendUrl = 'https://your-backend-url.vercel.app';
   ```
   Replace with your actual Vercel URL from Step 1.

2. **Build and deploy Flutter web**:
   ```bash
   flutter clean
   flutter build web --release
   cd build/web
   git init
   git add .
   git commit -m "Secure deployment with backend"
   git branch -M gh-pages
   git remote add origin https://github.com/polinapodnozova/buteyko-world-ai.git
   git push -f origin gh-pages
   ```

### Step 3: Test Your App

1. Visit: https://polinapodnozova.github.io/buteyko-world-ai
2. Try starting a breathing session
3. Check browser console (F12) for any errors

## Troubleshooting

### CORS Errors
If you see CORS errors in browser console:
- Go to Vercel dashboard → Your backend → Settings → Environment Variables
- Make sure `ALLOWED_ORIGINS` includes your GitHub Pages URL
- Redeploy: `vercel --prod`

### Backend Not Responding
- Check backend is running: Visit your-backend-url.vercel.app/health
- Should return: `{"status":"ok","service":"Buteyko World Backend"}`

### API Keys Not Working
- Verify keys are set in Vercel dashboard (Settings → Environment Variables)
- Make sure you used NEW keys (not the leaked ones!)
- Keys should NOT have quotes around them in Vercel

## Alternative: Railway Deployment

If you prefer Railway over Vercel:

1. Go to https://railway.app
2. Sign up/login with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Set root directory to `/backend`
6. Add environment variables in Variables tab
7. Deploy!

Railway gives you a URL like: `buteyko-backend.up.railway.app`

## Security Checklist

✅ Backend deployed with environment variables  
✅ Flutter app pointing to backend  
✅ Old API keys revoked and new ones generated  
✅ `.env` files are in `.gitignore`  
✅ Backend CORS configured for your domain only  
✅ Tested production app

## Costs

- **Vercel Free Tier**: 100GB bandwidth, unlimited deployments ✅
- **Railway Free Tier**: $5 credit/month, usually enough for small apps ✅
- Both are FREE for your app's traffic level!

## Next Steps

After deployment:
1. Test thoroughly on your live site
2. Monitor backend logs in Vercel/Railway dashboard
3. Set up uptime monitoring (optional): https://uptimerobot.com
4. Consider adding rate limiting for production traffic

## Need Help?

Backend not working? Check:
1. Vercel/Railway deployment logs
2. Environment variables are set correctly
3. Flutter app has correct backend URL
4. Browser console for errors (F12)
