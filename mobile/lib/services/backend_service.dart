import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'dart:io';

class BackendService {
  static const String _baseUrl = AppConfig.backendUrl;
  static const String _apiKey = AppConfig.apiKey;
  static const String _scanEndpoint = '/api/mobile-scan';

  static BackendService? _instance;
  static BackendService get instance =>
      _instance ??= BackendService._internal();

  BackendService._internal();

  String? _deviceId;

  Future<void> initialize() async {
    _deviceId = await _getDeviceId();
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = 'ios_${iosInfo.identifierForVendor ?? 'unknown'}';
      } else {
        deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }

      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

  Future<ScanResult> sendScanData(String qrData) async {
    try {
      if (_deviceId == null) {
        await initialize();
      }

      final body = {
        'qr_data': qrData,
        'device_id': _deviceId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_scanEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': _apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ScanResult.fromJson(data);
      } else {
        throw Exception('Failed to send scan data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class ScanResult {
  final bool success;
  final Map<String, dynamic>? scanResult;
  final String? error;

  ScanResult({
    required this.success,
    this.scanResult,
    this.error,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      success: json['success'] ?? false,
      scanResult: json['scan_result'],
      error: json['error'],
    );
  }
}
