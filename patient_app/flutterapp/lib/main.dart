import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'services/notification_service.dart';

/// Entry-Point für Benachrichtigungs-Aktionen,
/// die ausgeführt werden, wenn die App im Hintergrund
/// oder beendet ist (separater Isolate).
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  if (response.payload == null) return;

  // Plant die nächste Erinnerung basierend auf den
  // im Payload gespeicherten Informationen
  await NotificationService.scheduleNextFromPayload(response.payload!);
}

Future<void> main() async {
  // Notwendig für Plugin-Initialisierung vor runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisierung nur für mobile Plattformen
  if (!kIsWeb) {
    // Initialisiert die lokale Zeitzone (DST-sicher)
    await NotificationService.configureLocalTimeZone();

    // Initialisiert das Notification-Plugin und registriert
    // den Background-Callback
    await NotificationService.init(
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackground,
    );
    await NotificationService.testNotificationAfter5Seconds();

  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patient App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
