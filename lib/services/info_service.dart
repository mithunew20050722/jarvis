import 'dart:convert';
import 'package:http/http.dart' as http;

class InfoService {
  static Future<String> weather(String city) async {
    try {
      final r = await http
          .get(Uri.parse('https://wttr.in/${Uri.encodeComponent(city)}?format=3'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return r.body.trim();
    } catch (_) {}
    return 'Could not fetch weather.';
  }

  static Future<String> joke() async {
    try {
      final r = await http
          .get(Uri.parse('https://v2.jokeapi.dev/joke/Any?type=single'))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(r.body);
      return data['joke'] ?? 'Could not fetch a joke.';
    } catch (_) {
      return 'Could not fetch a joke.';
    }
  }

  static Future<String> advice() async {
    try {
      final r = await http
          .get(Uri.parse('https://api.adviceslip.com/advice'))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(r.body);
      return data['slip']?['advice'] ?? 'Could not fetch advice.';
    } catch (_) {
      return 'Could not fetch advice.';
    }
  }
}
