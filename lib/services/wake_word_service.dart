import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'tts_service.dart';
import '../brain/router.dart';

/// Continuously listens for the wake word "jarvis" using Android's native
/// SpeechRecognizer (via the speech_to_text plugin), then routes whatever
/// comes after it to the command router. Runs in a loop so it effectively
/// never stops listening — this is the actual "Google Assistant style"
/// piece, kept alive in the background by ListenerService.kt's foreground
/// notification.
class WakeWordService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _running = false;
  bool _awaitingCommand = false;

  void Function(String status)? onStatusChange;

  Future<void> start() async {
    final available = await _speech.initialize(
      onStatus: _handleEngineStatus,
      onError: (e) => _report('Mic error: ${e.errorMsg}'),
    );

    if (!available) {
      _report('Speech recognizer not available on this device.');
      return;
    }

    _running = true;
    _report('Listening for "jarvis"...');
    _listenCycle();
  }

  void stop() {
    _running = false;
    _speech.stop();
  }

  void _handleEngineStatus(String status) {
    // When the recognizer naturally stops (it can only listen for a
    // bounded window at a time), immediately start the next cycle so it
    // feels continuous rather than one-shot.
    if (status == 'done' || status == 'notListening') {
      if (_running) {
        Future.delayed(const Duration(milliseconds: 300), _listenCycle);
      }
    }
  }

  Future<void> _listenCycle() async {
    if (!_running) return;

    await _speech.listen(
      onResult: _handleResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _handleResult(stt.SpeechRecognitionResult result) {
    final heard = result.recognizedWords.toLowerCase();
    if (heard.isEmpty) return;

    if (!_awaitingCommand) {
      if (heard.contains('jarvis')) {
        _awaitingCommand = true;
        _report('Wake word detected — listening for command...');
        TtsService.speak('ඔව්, කියන්න');
        // Extract anything said right after "jarvis" in the same
        // utterance (e.g. "jarvis open whatsapp") as a fast path.
        final after = heard.split('jarvis').last.trim();
        if (after.isNotEmpty && result.finalResult) {
          _dispatch(after);
        }
      }
    } else if (result.finalResult) {
      _dispatch(heard);
    }
  }

  void _dispatch(String command) {
    _awaitingCommand = false;
    _report('Running: $command');
    CommandRouter.handle(command).then((_) {
      _report('Listening for "jarvis"...');
    });
  }

  void _report(String status) {
    onStatusChange?.call(status);
  }
}
