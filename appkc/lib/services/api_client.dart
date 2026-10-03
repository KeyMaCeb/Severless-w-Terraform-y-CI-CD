import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080", // 10.0.2.2 = localhost de tu PC visto desde el emulador
    connectTimeout: const Duration(seconds: 10),
  ));

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static void init() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: "jwt_token");
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
      onError: (DioException error, handler) {
        // Aquí luego podemos manejar el 401 (token vencido) globalmente
        handler.next(error);
      },
    ));
  }

  static Future<void> guardarToken(String token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

  static Future<void> borrarToken() async {
    await _storage.delete(key: "jwt_token");
  }

  static Future<String?> obtenerToken() async {
    return await _storage.read(key: "jwt_token");
  }
}