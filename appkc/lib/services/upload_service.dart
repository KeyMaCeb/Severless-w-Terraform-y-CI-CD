import 'dart:io';
import 'package:dio/dio.dart';
import '../models/upload_response.dart';
import 'api_client.dart';

class UploadService {
  Future<UploadResponse> subir(
    File archivo,
    int usuarioId,
    void Function(double progreso) onProgress,
  ) async {
    final nombreArchivo = archivo.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(archivo.path, filename: nombreArchivo),
      'usuarioId': usuarioId.toString(),
    });

    final res = await ApiClient.dio.post(
      '/upload',
      data: formData,
      onSendProgress: (enviado, total) {
        if (total > 0) onProgress(enviado / total);
      },
    );

    return UploadResponse.fromJson(res.data);
  }
}