import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/wake_word_service.dart';
import 'services/tts_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _channel = MethodChannel('jarvis/listener');
  String status = 'Starting...';
  final wakeWordService = WakeWordService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final statuses = await [
      Permission.microphone,
      Permission.notification,
    ].request();

    if (statuses[Permission.microphone]?.isGranted ?? false) {
      try {
        await _channel.invokeMethod('startListenerService');
      } catch (_) {}
    }

    await TtsService.speak('JARVIS ready. Background listening started.');

    wakeWordService.onStatusChange = (s) {
      if (mounted) setState(() => status = s);
    };
    await wakeWordService.start();
  }

  @override
  void dispose() {
    wakeWordService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JARVIS')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 96, color: Colors.cyanAccent),
              const SizedBox(height: 24),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              const Text(
                'Say "jarvis" anytime — even with the screen off.\n'
                'This screen can be closed; listening continues in the '
                'background (see the persistent notification).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
