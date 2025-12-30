// lib/services/web_notification_service.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebNotificationService {
  static void showNotification() {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        html.Notification(
          'Test Erinnerung',
          body: 'Bitte nehmen Sie Ihr Medikament!',
        );
      }
    });
  }
}
