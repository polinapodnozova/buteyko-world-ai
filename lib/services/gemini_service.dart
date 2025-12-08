import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class GeminiContentService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  /// Generates unique Buteyko breathing guidance using Gemini AI
  Future<List<Map<String, dynamic>>> generateBreathingGuidance(int durationMinutes) async {
    try {
      if (AppConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        // Fallback to static content if no API key
        return _getStaticGuidance();
      }

      final prompt = _createPrompt(durationMinutes);
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=${AppConfig.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final generatedText = responseData['candidates'][0]['content']['parts'][0]['text'];
        return _parseGuidanceSteps(generatedText);
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return _getStaticGuidance();
      }
    } catch (e) {
      print('Gemini Error: $e');
      return _getStaticGuidance();
    }
  }

  String _createPrompt(int durationMinutes) {
    return '''
Create a beautiful, calming Buteyko breathing guidance script for a $durationMinutes-minute session. 

Use rich figurative language and nature imagery to guide deep relaxation. Include metaphors like:
- Flowing honey, warm rain, melting butter
- Trees, flowers, mountains, clouds
- Balloons, feathers, gentle streams
- Christmas ornaments, silk curtains

Structure: Welcome -> Posture -> Eye closure -> Progressive relaxation (head to feet) -> Breathing focus -> Healing warmth release

Format your response as JSON array with this structure:
[
  {
    "text": "Welcome to your breathing journey...",
    "pauseAfter": 6
  },
  {
    "text": "Imagine warm honey flowing...",
    "pauseAfter": 8
  }
]

Create ${durationMinutes == 5 ? '12-15' : '18-22'} steps total. Use pauses between 6-25 seconds. Make each session unique with different imagery while maintaining the same calming progression.
''';
  }

  List<Map<String, dynamic>> _parseGuidanceSteps(String generatedText) {
    try {
      // Try to extract JSON from the generated text
      final jsonStart = generatedText.indexOf('[');
      final jsonEnd = generatedText.lastIndexOf(']') + 1;
      
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonText = generatedText.substring(jsonStart, jsonEnd);
        final List<dynamic> steps = jsonDecode(jsonText);
        
        return steps.map((step) => {
          'text': step['text'] ?? '',
          'pauseAfter': step['pauseAfter'] ?? 8,
        }).toList();
      }
    } catch (e) {
      print('Error parsing generated guidance: $e');
    }
    
    // Fallback to static content if parsing fails
    return _getStaticGuidance();
  }

  List<Map<String, dynamic>> _getStaticGuidance() {
    final random = Random();
    
    // Random variations for each step
    final welcomes = [
      'Welcome to your Buteyko breathing journey. Find a comfortable seat and feel yourself grounding like an ancient tree.',
      'Begin your healing Buteyko practice. Settle into your space feeling stable and rooted like a mountain.',
      'Welcome to this moment of peace. Sit comfortably and feel the earth supporting you like a strong foundation.',
    ];
    
    final postures = [
      'Imagine you are suspended by invisible silk threads from the crown of your head, naturally elongating your spine.',
      'Picture yourself as a beautiful Christmas tree ornament, gently suspended by a thread at the top of your head.',
      'Think of yourself as a graceful flower stem, rising naturally toward the warm sunlight above.',
    ];
    
    final eyeClosures = [
      'Gently close your eyes like soft petals folding at dusk, and lift your inner gaze toward infinite space.',
      'Let your eyelids drift closed like soft curtains drawing at the end of a peaceful day.',
      'Close your eyes gently, as if watching fluffy clouds drifting across an endless serene sky.',
    ];
    
    final headRelaxations = [
      'Feel warm golden light beginning to cascade from your scalp, melting away all tension like spring snow.',
      'Imagine warm honey melting from the very top of your head, flowing down like liquid sunshine.',
      'Picture gentle warm rain beginning to fall on the crown of your head, washing away all stress.',
    ];
    
    final faceRelaxations = [
      'This healing warmth flows over your face, releasing your jaw like a flower opening to morning sunlight.',
      'The warmth cascades over your forehead and cheeks, dissolving tension like butter melting.',
      'Feel this soothing flow over your face, softening your jaw like silk in a warm breeze.',
    ];
    
    final shoulderRelaxations = [
      'Gentle rain of relaxation falls on your shoulders, washing away the weight of the world.',
      'Your shoulders drop naturally, like autumn leaves falling softly to the earth.',
      'Feel your shoulders releasing, melting down like warm wax from a candle.',
    ];
    
    final armRelaxations = [
      'Your arms become soft and heavy, like silk scarves floating in a warm breeze.',
      'This healing energy flows down your arms, making them feel wonderfully heavy and peaceful.',
      'Your arms surrender to gravity, soft and warm like fresh bread dough.',
    ];
    
    final wristRelaxations = [
      'Now your wrists begin to expand like gentle balloons, becoming wonderfully heavy and warm.',
      'Your wrists are the gateway to deep peace. Feel them inflating softly, growing warm and heavy.',
      'Imagine your wrists becoming like soft pillows, expanding with healing warmth.',
    ];
    
    final bellyRelaxations = [
      'This beautiful warmth spreads through your torso, your belly rising and falling like ocean waves.',
      'Your abdomen softens like butter melting in gentle morning sunlight.',
      'Feel your belly becoming soft and warm, rising and falling naturally like breathing earth.',
    ];
    
    final feetRelaxations = [
      'Your feet join this dance of relaxation, growing warm and heavy like they are embracing the entire earth.',
      'Now your feet begin to expand, becoming warm heavy balloons of complete peace.',
      'Your feet settle and spread, becoming one with the ground, warm and infinitely heavy.',
    ];
    
    final breathingFocus = [
      'Now simply breathe naturally, feeling the healing warmth radiating from your completely relaxed body.',
      'Allow your breath to flow effortlessly, like a gentle breeze through flower petals.',
      'Breathe softly and naturally, releasing waves of healing energy throughout your being.',
    ];
    
    return [
      {'text': welcomes[random.nextInt(welcomes.length)], 'pauseAfter': 6},
      {'text': postures[random.nextInt(postures.length)], 'pauseAfter': 8},
      {'text': eyeClosures[random.nextInt(eyeClosures.length)], 'pauseAfter': 7},
      {'text': headRelaxations[random.nextInt(headRelaxations.length)], 'pauseAfter': 9},
      {'text': faceRelaxations[random.nextInt(faceRelaxations.length)], 'pauseAfter': 8},
      {'text': shoulderRelaxations[random.nextInt(shoulderRelaxations.length)], 'pauseAfter': 9},
      {'text': armRelaxations[random.nextInt(armRelaxations.length)], 'pauseAfter': 8},
      {'text': wristRelaxations[random.nextInt(wristRelaxations.length)], 'pauseAfter': 10},
      {'text': bellyRelaxations[random.nextInt(bellyRelaxations.length)], 'pauseAfter': 9},
      {'text': feetRelaxations[random.nextInt(feetRelaxations.length)], 'pauseAfter': 11},
      {'text': breathingFocus[random.nextInt(breathingFocus.length)], 'pauseAfter': 15},
    ];
  }
}