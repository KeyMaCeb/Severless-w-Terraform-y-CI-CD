import '../models/usuario.dart';
import 'api_client.dart';

class UsuarioService {
  static const _base = '/api/usuarios';

  Future<List<Usuario>> listar() async {
    final res = await ApiClient.dio.get(_base);
    return (res.data as List).map((e) => Usuario.fromJson(e)).toList();
  }

  Future<Usuario> buscarPorId(int id) async {
    final res = await ApiClient.dio.get('$_base/$id');
    return Usuario.fromJson(res.data);
  }

  Future<Usuario> crear(Usuario u, String password) async {
    final res = await ApiClient.dio.post(_base, data: u.toJson(password: password));
    return Usuario.fromJson(res.data);
  }

  Future<Usuario> actualizar(int id, Usuario u, {String? password}) async {
    final res = await ApiClient.dio.put('$_base/$id', data: u.toJson(password: password));
    return Usuario.fromJson(res.data);
  }

  Future<void> eliminar(int id) async {
    await ApiClient.dio.delete('$_base/$id');
  }
}