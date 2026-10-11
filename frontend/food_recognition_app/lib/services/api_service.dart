import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/prediction_result.dart';

class BackendStatus {
  final bool isBackendOnline;
  final bool isFlaskOnline;
  final String message;

  BackendStatus({
    required this.isBackendOnline,
    required this.isFlaskOnline,
    required this.message,
  });
}

class ApiService {
  /// Detailed health check of Node.js Express server and Flask ML server with auto-discovery probing.
  static Future<BackendStatus> checkBackendStatus() async {
    // 1. Try current active URL first
    final currentStatus = await _probeUrl(ApiConfig.baseUrl);
    if (currentStatus.isBackendOnline) {
      return currentStatus;
    }

    // 2. Auto-probe candidate URLs (e.g. Wi-Fi IP, emulator loopback, adb reverse, localhost)
    for (final candidate in ApiConfig.candidateUrls) {
      if (candidate == ApiConfig.baseUrl) continue;
      final status = await _probeUrl(candidate);
      if (status.isBackendOnline) {
        ApiConfig.setBaseUrl(candidate);
        return status;
      }
    }

    return BackendStatus(
      isBackendOnline: false,
      isFlaskOnline: false,
      message: 'Backend Server Unreachable at ${ApiConfig.baseUrl}',
    );
  }

  static Future<BackendStatus> _probeUrl(String baseUrl) async {
    try {
      final healthUrl = '$baseUrl/api/health';
      final response = await http
          .get(Uri.parse(healthUrl))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 503) {
        final Map<String, dynamic> data = json.decode(response.body);
        final bool backendOk = data['backend'] == 'ok';
        final bool flaskOk = data['flask'] == 'ok';

        if (backendOk && flaskOk) {
          return BackendStatus(
            isBackendOnline: true,
            isFlaskOnline: true,
            message: 'Backend & ML Model Online',
          );
        } else if (backendOk) {
          return BackendStatus(
            isBackendOnline: true,
            isFlaskOnline: false,
            message: 'Node.js Backend Online (Flask ML Server Unreachable)',
          );
        }
      }
      return BackendStatus(
        isBackendOnline: false,
        isFlaskOnline: false,
        message: 'Backend Server Unreachable at $baseUrl',
      );
    } catch (_) {
      return BackendStatus(
        isBackendOnline: false,
        isFlaskOnline: false,
        message: 'Backend Server Unreachable at $baseUrl',
      );
    }
  }

  /// Checks if the Node.js Express backend is online (returns boolean for simple UI states).
  static Future<bool> checkBackendHealth() async {
    final status = await checkBackendStatus();
    return status.isBackendOnline;
  }

  /// Sends an image file/xfile and portion weight to Node.js backend POST /api/predict.
  static Future<PredictionResponse> predictFoodImage({
    required String filePath,
    XFile? xFile,
    double portionGrams = 100.0,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.predictUrl),
      );

      request.fields['portion_grams'] = portionGrams.toStringAsFixed(0);

      http.MultipartFile file;
      if (kIsWeb) {
        final bytes = xFile != null ? await xFile.readAsBytes() : await XFile(filePath).readAsBytes();
        final name = xFile?.name ?? 'uploaded_image.jpg';
        file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: name,
        );
      } else {
        file = await http.MultipartFile.fromPath(
          'image',
          filePath,
        );
      }

      request.files.add(file);

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 25),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return PredictionResponse.fromJson(jsonMap);
      } else {
        try {
          final Map<String, dynamic> errJson = json.decode(response.body);
          return PredictionResponse(
            success: false,
            error: errJson['error'] ?? 'Server error (${response.statusCode})',
          );
        } catch (_) {
          return PredictionResponse(
            success: false,
            error: 'Server returned error status code ${response.statusCode}.',
          );
        }
      }
    } on TimeoutException {
      return PredictionResponse(
        success: false,
        error: 'Connection timed out. Please check if the Node.js backend is running.',
      );
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('SocketException') ||
          errStr.contains('ClientException') ||
          errStr.contains('Connection refused') ||
          errStr.contains('Failed to connect')) {
        return PredictionResponse(
          success: false,
          error: 'Cannot connect to backend server at ${ApiConfig.baseUrl}. Make sure Node.js server is running.',
        );
      }
      return PredictionResponse(
        success: false,
        error: 'An unexpected error occurred: $errStr',
      );
    }
  }
}

