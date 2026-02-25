import 'package:dio/dio.dart';
import 'package:eduprova/globals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

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

class AuthNotifier extends Notifier<AuthState> {
  // static const _storage = FlutterSecureStorage(
  //   iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  //   mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  // );

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _repository = AuthRepository.instance;

  @override
  AuthState build() {
    // Proactively check status
    Future.microtask(_checkStatus);
    return .new();
  }

  Future<void> _checkStatus() async {
    try {
      // final token = await _storage.read(key: 'access_token');
      // final email = await _storage.read(key: 'user_email');
      final token = prefs.getString('access_token');
      final email = prefs.getString('user_email');

      if (token != null && email != null) {
        final user = await _repository.getProfile(email);
        state = state.copyWith(
          status: .authenticated,
          user: user,
          clearError: true,
        );
        return;
      }
    } catch (e) {
      log('Session verification failed: $e');
    }

    // await _storage.delete(key: 'access_token');
    // await _storage.delete(key: 'user_email');
    prefs.remove('access_token');
    prefs.remove('user_email');
    state = state.copyWith(status: .unauthenticated, clearError: true);
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await _repository.login(email, password);

      // await _storage.write(key: 'access_token', value: result.token);
      // await _storage.write(key: 'user_email', value: result.user.email);
      prefs.setString('access_token', result.token);
      prefs.setString('user_email', result.user.email);

      state = state.copyWith(
        status: .authenticated,
        user: result.user,
        clearError: true,
      );
    } on DioException catch (e) {
      log('Login Dio Error: ${e.response?.data}');
      state = state.copyWith(
        error: e.response?.data?['message'] ?? 'Login failed: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> register(Map<String, dynamic> userDetails) async {
    try {
      await _repository.register(userDetails);
      await login(
        userDetails['email'] as String,
        userDetails['password'] as String,
      );
    } on DioException catch (e) {
      var msg = e.response?.data?['message'];
      if (msg is List) msg = msg.join(', ');
      state = state.copyWith(error: msg ?? 'Registration failed: ${e.message}');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> googleSignIn() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '462093645547-jhgrjc5nv2g7kp1fnk2g0o263n9kd9fj.apps.googleusercontent.com',
      );

      final googleUser = await _googleSignIn.authenticate();
      final displayName = googleUser.displayName ?? '';
      final names = displayName.split(' ');

      final result = await _repository.socialLogin(
        email: googleUser.email,
        firstName: names.isNotEmpty ? names.first : '',
        lastName: names.length > 1 ? names.skip(1).join(' ') : '',
        googleId: googleUser.id,
        avatar: googleUser.photoUrl,
      );

      // await _storage.write(key: 'access_token', value: result.token);
      // await _storage.write(key: 'user_email', value: result.user.email);
      prefs.setString('access_token', result.token);
      prefs.setString('user_email', result.user.email);

      state = state.copyWith(
        status: .authenticated,
        user: result.user,
        clearError: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        error:
            e.response?.data?['message'] ?? 'Google Login failed: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    // await _storage.delete(key: 'access_token');
    // await _storage.delete(key: 'user_email');
    prefs.remove('access_token');
    prefs.remove('user_email');
    state = state.copyWith(
      status: .unauthenticated,
      user: null,
      clearError: true,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
