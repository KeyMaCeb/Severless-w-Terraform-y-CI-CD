import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  bool loading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.login(email, password);
      return true;
    } on DioException catch (e) {
      if (e.response == null) {
        error = 'No se pudo conectar con el servidor';
      } else {
        error = 'Credenciales inválidas';
      }
      return false;
    } catch (_) {
      error = 'Ocurrió un error inesperado';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _repo.logout();
}