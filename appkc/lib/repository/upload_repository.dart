import 'dart:io';
import '../services/upload_service.dart';

class UploadRepository {
  final UploadService _service;

  UploadRepository(this._service);

  Future<String> subir(File archivo, int usuarioId, void Function(double) onProgress) async {
    final respuesta = await _service.subir(archivo, usuarioId, onProgress);
    return respuesta.url;
  }
}