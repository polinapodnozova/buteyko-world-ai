import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../config/app_config.dart';

class ElevenLabsTTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  /// Speaks the provided text using backend TTS API
  Future<bool> speakText(String text, String voiceId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/elevenlabs/tts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'voiceId': voiceId,
          'model': AppConfig.elevenLabsModel,
          'stability': AppConfig.elevenLabsStability,
          'similarity': AppConfig.elevenLabsSimilarity,
        }),
      );

      if (response.statusCode == 200) {
        // Check if it's JSON error response
        final contentType = response.headers['content-type'];
        if (contentType?.contains('application/json') == true) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['useFallback'] == true) {
            print('Backend TTS unavailable, using fallback');
            await Future.delayed(Duration(seconds: 3));
            return true;
          }
        }
        
        // Backend returns audio bytes
        final audioBytes = response.bodyBytes;
        
        try {
          _isPlaying = true;
          
          // Create a data URL for the audio
          final audioDataUrl = 'data:audio/mpeg;base64,${base64Encode(audioBytes)}';
          await _audioPlayer.play(UrlSource(audioDataUrl));
          
          // Listen for completion
          _audioPlayer.onPlayerComplete.listen((event) {
            _isPlaying = false;
          });
          
          return true;
        } catch (e) {
          print('Audio playback error: $e');
          // Fallback: simulate speech duration
          _isPlaying = true;
          await Future.delayed(Duration(seconds: (text.length / 10).round()));
          _isPlaying = false;
          return true;
        }
      } else {
        print('Backend TTS API Error: ${response.statusCode} - ${response.body}');
        // Fallback for development
        print('TTS Fallback: $text');
        await Future.delayed(Duration(seconds: 3));
        return true;
      }
    } catch (e) {
      print('TTS Error: $e');
      // Fallback
      await Future.delayed(Duration(seconds: 3));
      return true;
    }
  }

  /// Waits for current speech to complete
  Future<void> waitForCompletion() async {
    while (_isPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Stops current speech
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  /// Releases resources
  void dispose() {
    _audioPlayer.dispose();
  }
}