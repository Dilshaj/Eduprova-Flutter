import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ApiClient {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Reverted to explicit local IP for physical devices or custom networks
      return 'http://192.168.1.100:4000';
    }
    return 'http://localhost:4000';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Dio get instance {
    // Prevent adding interceptors multiple times
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await _storage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            if (e.response?.statusCode == 401) {
              // Unauthenticated, could clear token or dispatcher event
              await _storage.delete(key: 'access_token');
            }
            return handler.next(e);
          },
        ),
      );
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
    return _dio;
  }
}
