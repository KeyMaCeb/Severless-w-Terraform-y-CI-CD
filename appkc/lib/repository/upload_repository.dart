import 'dart:typed_data';
import '../services/upload_service.dart';

class UploadRepository {
  final UploadService _service;

  UploadRepository(this._service);

  Future<String> subir(
    Uint8List bytes,
    String nombreArchivo,
    int usuarioId,
    void Function(double) onProgress,
  ) async {
    final respuesta = await _service.subir(
      bytes,
      nombreArchivo,
      usuarioId,
      onProgress,
    );

    return respuesta.url;
  }
}