import '../services/tts_service.dart';
import '../services/system_service.dart';
import '../services/app_manager_service.dart';
import '../services/whatsapp_service.dart';
import '../services/info_service.dart';

/// Same keyword-matching approach as the Termux version's brain/router.py —
/// simple, dependable, easy to extend without needing an LLM/API key.
class CommandRouter {
  static Future<void> handle(String rawCommand) async {
    final cmd = rawCommand.trim().toLowerCase();
    if (cmd.isEmpty) return;

    // --- apps ---
    if (cmd.startsWith('open ')) {
      final target = cmd.replaceFirst('open ', '').trim();
      final opened = await AppManagerService.openApp(target);
      if (!opened) await AppManagerService.openUrl(target);
      await TtsService.speak('$target open කරනවා');
      return;
    }

    if (cmd.contains('go home') || cmd.contains('home screen')) {
      await AppManagerService.goHome();
      return;
    }

    // --- system ---
    if (cmd.contains('battery')) {
      final status = await SystemService.batteryStatus();
      await TtsService.speak('Battery: $status');
      return;
    }

    if (cmd.contains('volume up')) {
      await SystemService.setVolume(1.0);
      return;
    }
    if (cmd.contains('volume down')) {
      await SystemService.setVolume(0.2);
      return;
    }
    if (cmd.contains('mute')) {
      await SystemService.setVolume(0.0);
      return;
    }

    if (cmd.contains('brightness')) {
      final match = RegExp(r'(\d+)').firstMatch(cmd);
      if (match != null) {
        final pct = int.parse(match.group(1)!).clamp(0, 100);
        await SystemService.setBrightness(pct / 100);
        await TtsService.speak('Brightness $pct% ට set කලා');
      }
      return;
    }

    if (cmd.contains('vibrate')) {
      await SystemService.vibrate();
      return;
    }

    // --- info ---
    if (cmd.contains('weather')) {
      final city = cmd.replaceAll('weather', '').replaceAll('in', '').trim();
      final result = await InfoService.weather(city.isEmpty ? 'colombo' : city);
      await TtsService.speak(result);
      return;
    }

    if (cmd.contains('joke')) {
      await TtsService.speak(await InfoService.joke());
      return;
    }

    if (cmd.contains('advice')) {
      await TtsService.speak(await InfoService.advice());
      return;
    }

    // --- whatsapp ---
    if (cmd.startsWith('whatsapp ')) {
      final parts = cmd.split(' ');
      if (parts.length >= 3) {
        final number = parts[1];
        final message = parts.sublist(2).join(' ');
        await TtsService.speak(
          await WhatsAppService.sendMessage(number, message),
        );
      } else {
        await TtsService.speak(
          'Number eka saha message eka danna: whatsapp <number> <message>',
        );
      }
      return;
    }

    // --- unknown ---
    await TtsService.speak('Mata eka theruna na.');
  }
}
