import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<void> login(String email, String password) async {
    final respuesta = await _service.login(email, password);
    await ApiClient.guardarToken(respuesta.token);
  }

  Future<void> logout() => ApiClient.borrarToken();

  Future<bool> haySesion() async {
    return (await ApiClient.obtenerToken()) != null;
  }
}