import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> init() async {
    debugPrint('Rutino: Bildirim servisi hazırlandı.');
  }

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required String time,
  }) async {
    debugPrint('Rutino: Hatırlatıcı planlandı -> $title ($time) [ID: $habitId]');
  }

  Future<void> cancelReminder(String habitId) async {
    debugPrint('Rutino: Hatırlatıcı iptal edildi [ID: $habitId]');
  }
}
