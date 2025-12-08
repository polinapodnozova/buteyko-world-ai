import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class VoiceProvider with ChangeNotifier {
  String _selectedVoiceKey = AppConfig.defaultVoiceKey;
  
  String get selectedVoiceKey => _selectedVoiceKey;
  
  String get selectedVoiceId => 
      AppConfig.availableVoices[_selectedVoiceKey]?['id'] ?? 
      AppConfig.availableVoices[AppConfig.defaultVoiceKey]!['id']!;
  
  String get selectedVoiceName => 
      AppConfig.availableVoices[_selectedVoiceKey]?['name'] ?? 
      AppConfig.availableVoices[AppConfig.defaultVoiceKey]!['name']!;
  
  String get selectedVoiceDescription => 
      AppConfig.availableVoices[_selectedVoiceKey]?['description'] ?? 
      AppConfig.availableVoices[AppConfig.defaultVoiceKey]!['description']!;

  VoiceProvider() {
    _loadVoicePreference();
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedVoiceKey = prefs.getString('selectedVoice') ?? AppConfig.defaultVoiceKey;
    notifyListeners();
  }

  Future<void> setVoice(String voiceKey) async {
    if (AppConfig.availableVoices.containsKey(voiceKey)) {
      _selectedVoiceKey = voiceKey;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedVoice', voiceKey);
      notifyListeners();
    }
  }
}
