import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Microphone permission so'rash
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('❌ Mikrofon ruxsati berilmadi');
        return false;
      }

      // Speech-to-text initialize
      _isInitialized = await _speech.initialize(
        onError: (error) => print('❌ Speech error: $error'),
        onStatus: (status) => print('🎤 Speech status: $status'),
      );

      print(
        _isInitialized ? '✅ Voice service initialized' : '❌ Voice init failed',
      );
      return _isInitialized;
    } catch (e) {
      print('❌ Voice initialization error: $e');
      return false;
    }
  }

  Future<String?> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    if (_isListening) {
      print('⚠️ Already listening');
      return null;
    }

    String recognizedText = '';

    try {
      _isListening = true;

      await _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          print('🎤 Recognized: $recognizedText');
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'uz_UZ', // O'zbek tili
        cancelOnError: true,
        partialResults: false,
      );

      // 10 soniya kutish
      await Future.delayed(const Duration(seconds: 4));

      await _speech.stop();
      _isListening = false;

      return recognizedText.isNotEmpty ? recognizedText : null;
    } catch (e) {
      print('❌ Listen error: $e');
      _isListening = false;
      return null;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  void dispose() {
    _speech.cancel();
    _isListening = false;
  }
}
