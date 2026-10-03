import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repository/usuario_repository.dart';

class UsuarioViewModel extends ChangeNotifier {
  final UsuarioRepository _repo;

  UsuarioViewModel(this._repo);

  List<Usuario> usuarios = [];
  bool loading = false;
  String? error;

  String _mensaje(DioException e) {
    final code = e.response?.statusCode;
    if (code == null) return 'No se pudo conectar con el servidor';
    if (code == 401 || code == 403) return 'Sesión expirada, inicia sesión otra vez';
    return 'Error del servidor ($code)';
  }

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await accion();
      return true;
    } on DioException catch (e) {
      error = _mensaje(e);
      return false;
    } catch (_) {
      error = 'Ocurrió un error inesperado';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> cargar() => _ejecutar(() async {
        usuarios = await _repo.listar();
      });

  Future<bool> crear(String nombre, String email, String password) async {
    final ok = await _ejecutar(() async {
      await _repo.crear(nombre, email, password);
    });
    if (ok) await cargar();
    return ok;
  }

  Future<bool> actualizar(int id, String nombre, String email, {String? password}) async {
    final ok = await _ejecutar(() async {
      await _repo.actualizar(id, nombre, email, password: password);
    });
    if (ok) await cargar();
    return ok;
  }

  Future<bool> eliminar(int id) async {
    final ok = await _ejecutar(() => _repo.eliminar(id));
    if (ok) {
      usuarios.removeWhere((u) => u.id == id);
      notifyListeners();
    }
    return ok;
  }
}