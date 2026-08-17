import 'package:battery_plus/battery_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:vibration/vibration.dart';

class SystemService {
  static final Battery _battery = Battery();

  static Future<String> batteryStatus() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return '$level%, ${state.name}';
  }

  static Future<void> setVolume(double level) async {
    // level 0.0 - 1.0
    await FlutterVolumeController.setVolume(level);
  }

  static Future<void> setBrightness(double level) async {
    // level 0.0 - 1.0
    await ScreenBrightness().setScreenBrightness(level);
  }

  static Future<void> vibrate({int durationMs = 500}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: durationMs);
    }
  }
}
