import 'package:dio/dio.dart';
import 'package:eduprova/globals.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String _overrideUrlKey = 'dev_base_url_override';
  static Dio? _dio;

  static String get baseUrl {
    final override = prefs.getString(_overrideUrlKey);
    if (override != null && override.isNotEmpty) {
      debugPrint('Using override URL: $override');
      return 'http://$override:4000';
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.10:4000';
    }
    debugPrint('Using iOS/Web URL: http://localhost:4000');
    return 'http://localhost:4000';
  }

  static String? get baseUrlOverride => prefs.getString(_overrideUrlKey);

  static Future<void> setBaseUrlOverride(String value) async {
    await prefs.setString(_overrideUrlKey, value.trim());
    _reset();
  }

  static Future<void> clearBaseUrlOverride() async {
    await prefs.remove(_overrideUrlKey);
    _reset();
  }

  static void _reset() {
    _dio?.close(force: true);
    _dio = null;
  }

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            debugPrint('Request: ${options.path}');

            final token = prefs.getString('access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            return handler.next(options);
          },
          onError: (e, handler) async {
            if (e.response?.statusCode == 401) {
              prefs.remove('access_token');
            }
            return handler.next(e);
          },
        ),
      );

      _dio!.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return _dio!;
  }
}
