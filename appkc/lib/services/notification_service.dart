import 'api_client.dart';

class NotificationService {
  Future<void> enviar(String email, String subject, String message) async {
    await ApiClient.dio.post('/notifications/send', data: {
      'email': email,
      'subject': subject,
      'message': message,
    });
  }
}