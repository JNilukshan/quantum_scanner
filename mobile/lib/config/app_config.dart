class AppConfig {
  // Backend Configuration
  static const String backendUrl =
      'http://192.168.1.100:5000'; // Change this to your server IP
  static const String apiKey =
      'changeme_scan_api_key'; // Change this to match your .env

  // App Information
  static const String appName = 'Quantum Scanner';
  static const String appVersion = '1.0.0';

  // Network Configuration
  static const int connectionTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

  // Development vs Production
  static const bool isProduction = false;
  static const bool enableLogging = true;
}
