import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Opens WhatsApp with a pre-filled message. Android does not allow
  /// silently sending on the user's behalf without root — the user taps
  /// Send in the app, same as the Termux version.
  static Future<String> sendMessage(String phoneNumber, String message) async {
    final uri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return ok
        ? 'WhatsApp message to $phoneNumber ready — tap Send.'
        : 'Could not open WhatsApp.';
  }
}
