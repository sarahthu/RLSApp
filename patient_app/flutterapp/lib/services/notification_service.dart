import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart'; // 🔴 WEB FIX: für kIsWeb

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🔹 Initialisierung (Android + iOS)
  static Future<void> init() async {
    if (kIsWeb) return; // 🔴 WEB FIX: Web unterstützt keine Notifications

    // Zeitzonen
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(tz.local.name));

    // Android Init
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Init
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // iOS: Permission abfragen (WICHTIG!)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // 🔹 Notification Details
  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'med_channel_id',
        'Medikament Erinnerung',
        channelDescription: 'Erinnert an die Einnahme von Medikamenten',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // 🔹 Test-Notification nach X Sekunden
  static Future<void> scheduleNotificationInSeconds(
      String title, String body, int seconds, int id) async {
    if (kIsWeb) return; // 🔴 WEB FIX

    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Tägliche Notification
  static Future<void> scheduleDailyNotification(
      String title, String body, DateTime time, int id) async {
    if (kIsWeb) return; // 🔴 WEB FIX

    final scheduledDate = _nextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 🔹 Berechnet nächsten Zeitpunkt
  static tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // 🔹 Einmalige Notification
  static Future<void> scheduleOneTimeNotification(
    String title,
    String body,
    DateTime dateTime,
    int id,
  ) async {
    if (kIsWeb) return; // 🔴 WEB FIX

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Wöchentliche Notification
  static Future<void> scheduleWeeklyNotification(
    String title,
    String body,
    DateTime dateTime,
    int id,
  ) async {
    if (kIsWeb) return; // 🔴 WEB FIX

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // 🔹 Monatliche Notification
  static Future<void> scheduleMonthlyNotification(
    String title,
    String body,
    DateTime dateTime,
    int id,
  ) async {
    if (kIsWeb) return; // WEB FIX

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  // 🔹 Notification löschen
  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return; // WEB FIX
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
