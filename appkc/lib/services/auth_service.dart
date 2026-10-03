import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import 'api_client.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final res = await ApiClient.dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
      options: Options(responseType: ResponseType.plain),
    );
    return AuthResponse(token: res.data.toString());
  }
}