import 'package:flutter/foundation.dart';
import '../repository/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repo;

  NotificationViewModel(this._repo);

  bool enviando = false;

  Future<bool> enviar(String email, String subject, String message) async {
    enviando = true;
    notifyListeners();
    try {
      await _repo.enviar(email, subject, message);
      return true;
    } catch (e) {
      debugPrint('NOTIF ERROR: $e');
      return false;
    } finally {
      enviando = false;
      notifyListeners();
    }
  }
}