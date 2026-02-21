import 'package:dio/dio.dart';
import 'package:edupurva/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

import '../models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkStatus();
  }

  static const _storage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _checkStatus() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final email = await _storage.read(key: 'user_email');

      if (token != null && email != null) {
        // Validate session by fetching profile
        final response = await ApiClient.instance.get('/auth/profile/$email');
        if (response.statusCode == 200) {
          final user = UserModel.fromJson(response.data);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          );
          return;
        }
      }
    } catch (e) {
      log('Session verification failed: $e');
      // Token might be expired or invalid, fall through
    }

    // Clear storage just in case if invalid
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_email');
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearError: true,
    );
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['access_token'];
        final user = UserModel.fromJson(data['user']);

        await _storage.write(key: 'access_token', value: token);
        await _storage.write(key: 'user_email', value: user.email);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      }
    } on DioException catch (e) {
      log(
        'Login Dio Error: type=${e.type}, message=${e.message}, error=${e.error}',
      );
      log('Login details: ${e.response?.data}');
      state = state.copyWith(
        error: e.response?.data?['message'] ?? 'Login failed: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> register(Map<String, dynamic> userDetails) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/register',
        data: userDetails,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Automatically log them in with the details used to register
        await login(userDetails['email'], userDetails['password']);
      }
    } on DioException catch (e) {
      log(
        'Reg Dio Error: type=${e.type}, message=${e.message}, error=${e.error}',
      );
      log('Reg details: ${e.response?.data}');
      // NestJS generic exception format is usually { "message": ["array of errors"] } or { "message": "error string" }
      var msg = e.response?.data?['message'];
      if (msg is List) msg = msg.join(', ');
      state = state.copyWith(error: msg ?? 'Registration failed: ${e.message}');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> googleSignIn() async {
    try {
      // Must call initialize once per the v7 package docs (safe to call multiple times internally if it checks, though here it's fine)
      await _googleSignIn.initialize(
        serverClientId:
            '462093645547-jhgrjc5nv2g7kp1fnk2g0o263n9kd9fj.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      final String email = googleUser!.email;
      final String displayName = googleUser.displayName ?? '';
      final String id = googleUser.id;
      final String? photoUrl = googleUser.photoUrl;

      // Extract raw first and last names if available (basic splitting since Google mostly gives a single displayName)
      final names = displayName.split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.skip(1).join(' ') : '';

      final response = await ApiClient.instance.post(
        '/auth/social-login',
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'googleId': id,
          'avatar': photoUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data['access_token'];
        final user = UserModel.fromJson(data['user']);

        await _storage.write(key: 'access_token', value: token);
        await _storage.write(key: 'user_email', value: user.email);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      }
    } on DioException catch (e) {
      log(
        'Google Login Dio Error: type=${e.type}, message=${e.message}, error=${e.error}',
      );
      log('Google Login API details: ${e.response?.data}');
      state = state.copyWith(
        error:
            e.response?.data?['message'] ??
            'Google Login failed on server: ${e.message}',
      );
    } catch (e) {
      log('Google Login Client Error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_email');
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      clearError: true,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
