# Buteyko World Backend API

Secure backend proxy for Buteyko World AI Flutter app. Keeps API keys hidden from client-side code.

## Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
Copy `.env.example` to `.env` and add your API keys:
```bash
cp .env.example .env
```

Edit `.env`:
```
GEMINI_API_KEY=your_actual_gemini_key
ELEVENLABS_API_KEY=your_actual_elevenlabs_key
PORT=3000
ALLOWED_ORIGINS=https://polinapodnozova.github.io
```

### 3. Run Locally
```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

## API Endpoints

### Health Check
```
GET /health
```
Returns server status.

### Gemini Content Generation
```
POST /api/gemini/generate
Content-Type: application/json

{
  "prompt": "breathing guidance prompt",
  "durationMinutes": 5
}
```

### ElevenLabs TTS
```
POST /api/elevenlabs/tts
Content-Type: application/json

{
  "text": "Text to speak",
  "voiceId": "EXAVITQu4vr4xnSDxMaL",
  "model": "eleven_turbo_v2_5",
  "stability": 0.8,
  "similarity": 0.8
}
```

## Deployment Options

### Option 1: Vercel (Recommended - Free)
1. Install Vercel CLI: `npm i -g vercel`
2. Login: `vercel login`
3. Deploy: `vercel`
4. Add environment variables in Vercel dashboard
5. Deploy to production: `vercel --prod`

### Option 2: Railway
1. Visit [railway.app](https://railway.app)
2. Create new project from GitHub repo
3. Add environment variables in settings
4. Deploy automatically

### Option 3: Render
1. Visit [render.com](https://render.com)
2. Create new Web Service from GitHub
3. Add environment variables
4. Deploy

### Option 4: Your Own Server
```bash
# On your server
git clone [your-repo]
cd backend
npm install
npm start
```

Use PM2 for production:
```bash
npm i -g pm2
pm2 start server.js --name buteyko-backend
pm2 save
pm2 startup
```

## CORS Configuration

Update `ALLOWED_ORIGINS` in `.env` with your Flutter app URL:
```
ALLOWED_ORIGINS=https://polinapodnozova.github.io,https://yourdomain.com
```

## Security Notes

- Never commit `.env` file
- Rotate API keys regularly
- Use HTTPS in production
- Limit CORS origins to your domains only
- Consider adding rate limiting for production
