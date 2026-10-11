import 'package:flutter/foundation.dart';

class ApiConfig {
  /// User override or auto-discovered working backend URL
  static String? customBaseUrl;

  /// Candidate URLs to probe on physical device/emulator/web
  static List<String> get candidateUrls => [
        if (customBaseUrl != null && customBaseUrl!.isNotEmpty) customBaseUrl!,
        'http://10.130.177.159:5000', // Local Wi-Fi IP for Physical Android Phone
        'http://10.0.2.2:5000',      // Android Emulator Loopback
        'http://127.0.0.1:5000',     // Web / Desktop / ADB reverse
        'http://localhost:5000',
      ];

  /// Returns current active base URL
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (kIsWeb) return 'http://127.0.0.1:5000';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.130.177.159:5000'; // Default to PC Wi-Fi IP for physical phone
    }
    return 'http://127.0.0.1:5000';
  }

  static void setBaseUrl(String url) {
    var cleaned = url.trim();
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'http://$cleaned';
    }
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    customBaseUrl = cleaned;
  }

  static String get healthUrl => '$baseUrl/api/health';
  static String get nutritionUrl => '$baseUrl/api/nutrition';
  static String get predictUrl => '$baseUrl/api/predict';
}


