import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppSettings {
  final String unit; // 'metric' (g) or 'imperial' (oz)
  final String themeMode; // 'system', 'light', 'dark'
  final double dailyCalorieGoal;

  AppSettings({
    this.unit = 'metric',
    this.themeMode = 'light',
    this.dailyCalorieGoal = 2000.0,
  });

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'themeMode': themeMode,
        'dailyCalorieGoal': dailyCalorieGoal,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        unit: json['unit'] ?? 'metric',
        themeMode: json['themeMode'] ?? 'light',
        dailyCalorieGoal: (json['dailyCalorieGoal'] as num?)?.toDouble() ?? 2000.0,
      );

  AppSettings copyWith({
    String? unit,
    String? themeMode,
    double? dailyCalorieGoal,
  }) {
    return AppSettings(
      unit: unit ?? this.unit,
      themeMode: themeMode ?? this.themeMode,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    );
  }
}

class SettingsService {
  static const String _fileName = 'foodlens_settings.json';
  static AppSettings _currentSettings = AppSettings();
  static final ValueNotifier<AppSettings> settingsNotifier =
      ValueNotifier<AppSettings>(_currentSettings);

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<AppSettings> loadSettings() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final jsonMap = json.decode(content);
          _currentSettings = AppSettings.fromJson(jsonMap);
          settingsNotifier.value = _currentSettings;
          return _currentSettings;
        }
      }
    } catch (e) {
      debugPrint('SettingsService load error: $e');
    }
    return _currentSettings;
  }

  static Future<void> saveSettings(AppSettings settings) async {
    _currentSettings = settings;
    settingsNotifier.value = settings;
    try {
      final file = await _getFile();
      await file.writeAsString(json.encode(settings.toJson()));
    } catch (e) {
      debugPrint('SettingsService save error: $e');
    }
  }
}
