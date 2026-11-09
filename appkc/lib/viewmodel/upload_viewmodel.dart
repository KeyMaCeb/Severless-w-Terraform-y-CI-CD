import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../repository/upload_repository.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadRepository _repo;

  UploadViewModel(this._repo);

  bool subiendo = false;
  double progreso = 0;
  String? error;
  String? urlSubida;

  Future<bool> subir(
    Uint8List bytes,
    String nombreArchivo,
    int usuarioId,
  ) async {
    subiendo = true;
    progreso = 0;
    error = null;
    urlSubida = null;
    notifyListeners();

    try {
      urlSubida = await _repo.subir(
        bytes,
        nombreArchivo,
        usuarioId,
        (p) {
          progreso = p;
          notifyListeners();
        },
      );

      return true;
    } on DioException catch (e) {
      debugPrint(
        'UPLOAD ERROR: ${e.response?.statusCode} -> ${e.response?.data}',
      );
      debugPrint('UPLOAD MSG: ${e.message}');

      error =
          'No se pudo subir (${e.response?.statusCode ?? 'sin conexión'})';

      return false;
    } catch (e, st) {
      debugPrint('UPLOAD ERROR: $e\n$st');
      error = 'No se pudo subir el archivo';
      return false;
    } finally {
      subiendo = false;
      notifyListeners();
    }
  }

  void reset() {
    progreso = 0;
    error = null;
    urlSubida = null;
    notifyListeners();
  }
}