import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository(this._service);

  Future<void> enviar(String email, String subject, String message) =>
      _service.enviar(email, subject, message);
}