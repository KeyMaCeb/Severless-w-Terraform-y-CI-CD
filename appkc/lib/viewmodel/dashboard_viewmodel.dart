import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repository/usuario_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final UsuarioRepository _repo;

  DashboardViewModel(this._repo);

  bool loading = false;
  String? error;
  int? tiempoMs;

  List<Usuario> listaCompleta = [];
  Usuario? perfil;
  Usuario? configuracion;

  Future<void> cargarParalelo() async {
    loading = true;
    error = null;
    notifyListeners();

    final inicio = DateTime.now();

    try {
      // Las 3 peticiones salen AL MISMO TIEMPO, no una detrás de otra.
      final resultados = await Future.wait([
        _repo.listar(),          // "obtener usuarios"
        _repo.buscarPorId(1),    // "obtener perfil"
        _repo.buscarPorId(2),    // "obtener configuración"
      ]);

      listaCompleta = resultados[0] as List<Usuario>;
      perfil = resultados[1] as Usuario;
      configuracion = resultados[2] as Usuario;

      tiempoMs = DateTime.now().difference(inicio).inMilliseconds;
    } catch (_) {
      error = 'No se pudieron cargar los datos del dashboard';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}