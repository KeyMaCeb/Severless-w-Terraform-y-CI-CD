import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/upload_response.dart';
import 'api_client.dart';

class UploadService {
  Future<UploadResponse> subir(
    Uint8List bytes,
    String nombreArchivo,
    int usuarioId,
    void Function(double progreso) onProgress,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: nombreArchivo,
      ),
      'usuarioId': usuarioId.toString(),
    });

    final res = await ApiClient.dio.post(
      '/upload',
      data: formData,
      onSendProgress: (enviado, total) {
        if (total > 0) {
          onProgress(enviado / total);
        }
      },
    );

    return UploadResponse.fromJson(res.data);
  }
}