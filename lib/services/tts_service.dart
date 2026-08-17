import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _configured = false;

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _configured = true;
  }

  static Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _ensureConfigured();
    await _tts.speak(text);
  }
}
