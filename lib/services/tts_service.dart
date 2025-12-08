import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../config/app_config.dart';

class ElevenLabsTTSService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  /// Speaks the provided text using ElevenLabs Text-to-Speech
  Future<bool> speakText(String text, String voiceId) async {
    try {
      if (AppConfig.elevenLabsApiKey == 'YOUR_ELEVENLABS_API_KEY_HERE') {
        // Fallback for development - just print the text
        print('TTS (No API Key): $text');
        await Future.delayed(Duration(seconds: 3)); // Simulate speech time
        return true;
      }

      final url = '$_baseUrl/$voiceId';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': AppConfig.elevenLabsApiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': AppConfig.elevenLabsModel,
          'voice_settings': {
            'stability': AppConfig.elevenLabsStability,
            'similarity_boost': AppConfig.elevenLabsSimilarity,
            'style': 0.0,
            'use_speaker_boost': true,
          }
        }),
      );

      if (response.statusCode == 200) {
        // ElevenLabs returns audio directly as bytes
        final audioBytes = response.bodyBytes;
        
        try {
          // For web: create blob URL and play
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
        print('ElevenLabs TTS API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('TTS Error: $e');
      return false;
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