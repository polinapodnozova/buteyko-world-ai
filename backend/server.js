import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import fetch from 'node-fetch';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// CORS configuration
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['*'];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes('*') || allowedOrigins.some(allowed => {
      if (allowed.includes('*')) {
        const pattern = allowed.replace('*', '.*');
        return new RegExp(pattern).test(origin);
      }
      return allowed === origin;
    })) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
}));

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'Buteyko World Backend' });
});

// Gemini API proxy
app.post('/api/gemini/generate', async (req, res) => {
  try {
    const { prompt, durationMinutes } = req.body;

    if (!process.env.GEMINI_API_KEY || process.env.GEMINI_API_KEY === 'your_gemini_api_key_here') {
      return res.status(500).json({ 
        error: 'Gemini API key not configured',
        useFallback: true
      });
    }

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [{ text: prompt }]
          }],
          generationConfig: {
            temperature: 0.8,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          }
        }),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Gemini API Error:', errorText);
      return res.status(response.status).json({ 
        error: 'Gemini API request failed',
        useFallback: true 
      });
    }

    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Gemini Error:', error);
    res.status(500).json({ 
      error: error.message,
      useFallback: true 
    });
  }
});

// ElevenLabs TTS proxy
app.post('/api/elevenlabs/tts', async (req, res) => {
  try {
    const { text, voiceId, model, stability, similarity } = req.body;

    if (!process.env.ELEVENLABS_API_KEY || process.env.ELEVENLABS_API_KEY === 'your_elevenlabs_api_key_here') {
      return res.status(500).json({ 
        error: 'ElevenLabs API key not configured',
        useFallback: true
      });
    }

    const response = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
      {
        method: 'POST',
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': process.env.ELEVENLABS_API_KEY,
        },
        body: JSON.stringify({
          text,
          model_id: model || 'eleven_turbo_v2_5',
          voice_settings: {
            stability: stability || 0.8,
            similarity_boost: similarity || 0.8,
          }
        }),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('ElevenLabs API Error:', errorText);
      return res.status(response.status).json({ 
        error: 'ElevenLabs API request failed',
        useFallback: true
      });
    }

    // Stream the audio response
    res.setHeader('Content-Type', 'audio/mpeg');
    response.body.pipe(res);
  } catch (error) {
    console.error('ElevenLabs Error:', error);
    res.status(500).json({ 
      error: error.message,
      useFallback: true
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Buteyko World Backend running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`🔒 Environment: ${process.env.NODE_ENV || 'development'}`);
});
