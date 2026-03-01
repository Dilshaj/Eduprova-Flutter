import 'package:dio/dio.dart';
import 'package:eduprova/globals.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

// class ApiClient {
//   static String get baseUrl {
//     if (Platform.isAndroid) {
//       // Reverted to explicit local IP for physical devices or custom networks
//       return 'http://192.168.1.5:4000';
//     }
//     return 'http://localhost:4000';
//   }

//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//     ),
//   );

//   // static const FlutterSecureStorage _storage = FlutterSecureStorage(
//   //   iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
//   //   mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
//   // );

//   static Dio get instance {
//     // Prevent adding interceptors multiple times
//     if (_dio.interceptors.isEmpty) {
//       _dio.interceptors.add(
//         InterceptorsWrapper(
//           onRequest: (options, handler) async {
//             // print path
//             debugPrint('Request: ${options.path}');

//             // final token = await _storage.read(key: 'access_token');
//             final token = prefs.getString('access_token');
//             if (token != null) {
//               options.headers['Authorization'] = 'Bearer $token';
//             }
//             return handler.next(options);
//           },
//           onError: (DioException e, handler) async {
//             if (e.response?.statusCode == 401) {
//               // Unauthenticated, could clear token or dispatcher event
//               // await _storage.delete(key: 'access_token');
//               prefs.remove('access_token');
//             }
//             return handler.next(e);
//           },
//         ),
//       );
//       _dio.interceptors.add(
//         LogInterceptor(responseBody: true, requestBody: true),
//       );
//     }
//     return _dio;
//   }
// }

class ApiClient {
  static Dio? _dio;

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.4:4000';
      // return 'http://10.169.69.6:4000';
    }
    return 'http://localhost:4000';
  }

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
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
