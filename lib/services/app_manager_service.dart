import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:url_launcher/url_launcher.dart';

/// Replaces Termux's `am start` calls with native Android intents.
class AppManagerService {
  static const Map<String, String> appPackages = {
    'whatsapp': 'com.whatsapp',
    'youtube': 'com.google.android.youtube',
    'chrome': 'com.android.chrome',
    'camera': 'com.android.camera',
    'gallery': 'com.google.android.apps.photos',
    'settings': 'com.android.settings',
    'messages': 'com.google.android.apps.messaging',
    'maps': 'com.google.android.apps.maps',
    'gmail': 'com.google.android.gm',
    'play store': 'com.android.vending',
    'facebook': 'com.facebook.katana',
    'instagram': 'com.instagram.android',
    'spotify': 'com.spotify.music',
  };

  static Future<bool> openApp(String friendlyName) async {
    final pkg = appPackages[friendlyName.trim().toLowerCase()];
    if (pkg == null) return false;

    final intent = AndroidIntent(
      action: 'action_main',
      category: 'category_launcher',
      package: pkg,
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      await intent.launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> goHome() async {
    final intent = AndroidIntent(
      action: 'action_main',
      category: 'category_home',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
