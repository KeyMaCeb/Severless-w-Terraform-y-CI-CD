import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioRepository {
  final UsuarioService _service;

  UsuarioRepository(this._service);

  Future<List<Usuario>> listar() => _service.listar();

  Future<Usuario> buscarPorId(int id) => _service.buscarPorId(id);

  Future<Usuario> crear(String nombre, String email, String password) {
    return _service.crear(Usuario(nombre: nombre, email: email), password);
  }

  Future<Usuario> actualizar(int id, String nombre, String email, {String? password}) {
    return _service.actualizar(id, Usuario(id: id, nombre: nombre, email: email), password: password);
  }

  Future<void> eliminar(int id) => _service.eliminar(id);
}