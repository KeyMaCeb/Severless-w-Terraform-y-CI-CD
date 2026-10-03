import 'dart:io';
import 'package:flutter/foundation.dart';
import '../repository/upload_repository.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadRepository _repo;

  UploadViewModel(this._repo);

  bool subiendo = false;
  double progreso = 0;
  String? error;
  String? urlSubida;

  Future<bool> subir(File archivo, int usuarioId) async {
    subiendo = true;
    progreso = 0;
    error = null;
    urlSubida = null;
    notifyListeners();

    try {
      urlSubida = await _repo.subir(archivo, usuarioId, (p) {
        progreso = p;
        notifyListeners();
      });
      return true;
    } catch (_) {
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
  }
}