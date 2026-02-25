import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  static final AuthRepository instance = AuthRepository._internal();
  AuthRepository._internal();

  final Dio _dio = ApiClient.instance;

  Future<UserModel> getProfile(String email) async {
    final response = await _dio.get('/auth/profile/$email');
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }
    throw Exception('Failed to fetch profile');
  }

  Future<({String token, UserModel user})> login(
    String email,
    String password,
  ) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      return (
        token: data['access_token'] as String,
        user: UserModel.fromJson(data['user']),
      );
    }
    throw Exception('Login failed');
  }

  Future<void> register(Map<String, dynamic> userDetails) async {
    final response = await _dio.post('/auth/register', data: userDetails);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Registration failed');
    }
  }

  Future<({String token, UserModel user})> socialLogin({
    required String email,
    required String firstName,
    required String lastName,
    required String googleId,
    String? avatar,
  }) async {
    final response = await _dio.post(
      '/auth/social-login',
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'googleId': googleId,
        'avatar': avatar,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      return (
        token: data['access_token'] as String,
        user: UserModel.fromJson(data['user']),
      );
    }
    throw Exception('Social login failed');
  }
}
