import 'package:eduprova/globals.dart';

class LiveKitConfig {
  static const String _overrideUrlKey = 'dev_livekit_url_override';
  static const String _defaultUrl = 'wss://rahul-h1jumjl8.livekit.cloud';

  static String get serverUrl {
    final override = prefs.getString(_overrideUrlKey);
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return _defaultUrl;
  }

  static String resolve(String? rawValue) {
    final value = rawValue?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return serverUrl;
  }

  static Future<void> setServerUrlOverride(String value) async {
    await prefs.setString(_overrideUrlKey, value.trim());
  }

  static Future<void> clearServerUrlOverride() async {
    await prefs.remove(_overrideUrlKey);
  }
}
