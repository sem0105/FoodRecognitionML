import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ScanHistoryItem {
  final String id;
  final String foodName;
  final DateTime scannedAt;
  final double portionGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double confidence;
  final String? localImagePath;
  final String? note;
  final String? dataType;
  final String? sourceUrl;

  ScanHistoryItem({
    required this.id,
    required this.foodName,
    required this.scannedAt,
    required this.portionGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    this.localImagePath,
    this.note,
    this.dataType,
    this.sourceUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'scannedAt': scannedAt.toIso8601String(),
      'portionGrams': portionGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'confidence': confidence,
      'localImagePath': localImagePath,
      'note': note,
      'dataType': dataType,
      'sourceUrl': sourceUrl,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: json['foodName'] ?? 'Unknown Dish',
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt']) ?? DateTime.now()
          : DateTime.now(),
      portionGrams: (json['portionGrams'] as num?)?.toDouble() ?? 100.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      localImagePath: json['localImagePath'],
      note: json['note'],
      dataType: json['dataType'],
      sourceUrl: json['sourceUrl'],
    );
  }
}

class HistoryService {
  static const String _fileName = 'food_scan_history.json';
  static List<ScanHistoryItem>? _cachedHistory;

  static Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Copies an image file or bytes into an app-owned persistent directory
  static Future<String?> persistImage({
    File? originalFile,
    Uint8List? imageBytes,
  }) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final historyImgDir = Directory('${docsDir.path}/history_images');
      if (!await historyImgDir.exists()) {
        await historyImgDir.create(recursive: true);
      }

      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetFile = File('${historyImgDir.path}/$fileName');

      if (imageBytes != null && imageBytes.isNotEmpty) {
        await targetFile.writeAsBytes(imageBytes);
        return targetFile.path;
      } else if (originalFile != null && await originalFile.exists()) {
        await originalFile.copy(targetFile.path);
        return targetFile.path;
      }
    } catch (e) {
      debugPrint('HistoryService: Failed to persist image: $e');
    }
    return null;
  }

  /// Loads all history items, sorted newest first
  static Future<List<ScanHistoryItem>> getHistory() async {
    if (_cachedHistory != null) {
      return List.unmodifiable(_cachedHistory!);
    }

    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final List<dynamic> jsonList = json.decode(content);
          final items = jsonList
              .map((item) => ScanHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList();
          items.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
          _cachedHistory = items;
          return List.unmodifiable(_cachedHistory!);
        }
      }
    } catch (e) {
      debugPrint('HistoryService: Failed to read history: $e');
    }

    _cachedHistory = [];
    return [];
  }

  /// Adds a new scan history entry
  static Future<void> addHistoryItem(ScanHistoryItem item) async {
    final current = await getHistory();
    final updated = List<ScanHistoryItem>.from(current);

    // Prevent duplicate entries if already present with same ID
    final existingIdx = updated.indexWhere((e) => e.id == item.id);
    if (existingIdx != -1) {
      return;
    }

    updated.insert(0, item);
    _cachedHistory = updated;
    await _saveToDisk(updated);
  }

  /// Deletes a scan history entry by ID
  static Future<void> deleteHistoryItem(String id) async {
    final current = await getHistory();
    final updated = List<ScanHistoryItem>.from(current);

    final itemToDelete = updated.firstWhere(
      (e) => e.id == id,
      orElse: () => ScanHistoryItem(
        id: '',
        foodName: '',
        scannedAt: DateTime.now(),
        portionGrams: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        confidence: 0,
      ),
    );

    if (itemToDelete.id.isNotEmpty && itemToDelete.localImagePath != null) {
      try {
        final imgFile = File(itemToDelete.localImagePath!);
        if (await imgFile.exists()) {
          await imgFile.delete();
        }
      } catch (_) {}
    }

    updated.removeWhere((e) => e.id == id);
    _cachedHistory = updated;
    await _saveToDisk(updated);
  }

  /// Clears all history
  static Future<void> clearAll() async {
    _cachedHistory = [];
    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static Future<void> _saveToDisk(List<ScanHistoryItem> items) async {
    try {
      final file = await _getHistoryFile();
      final jsonList = items.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('HistoryService: Failed to write history: $e');
    }
  }
}
