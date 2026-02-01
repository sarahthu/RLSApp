import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Zentrale Service-Klasse für lokale Benachrichtigungen.
/// Kapselt Initialisierung, Berechtigungen und Scheduling.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Fester Notification-Channel für Medikamenten-Erinnerungen (Android)
  static const String _channelId = 'med_channel_id';
  static const String _channelName = 'Medikament Erinnerung';
  static const String _channelDescription =
      'Erinnert an die Einnahme von Medikamenten';

  /// Initialisiert die lokale Zeitzone des Geräts.
  /// Notwendig für DST-sicheres Scheduling.
  static Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    //final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    //tz.setLocalLocation(tz.getLocation(timeZoneName));
    tz.setLocalLocation(tz.getLocation("Europe/Berlin"));
  }

  /// Initialisiert das Notification-Plugin und registriert Callbacks.
  static Future<void> init({
    required Function(NotificationResponse)
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    if (kIsWeb) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-Permissions werden bewusst später angefragt
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    await _requestPermissions();
  }

  /// Fordert die notwendigen Laufzeit-Berechtigungen an
  /// (Android 13+ / iOS).
  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Callback für Benachrichtigungen im Vordergrund.
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification geöffnet: ${response.payload}');
  }

  /// Zentrale Notification-Konfiguration für alle Benachrichtigungen.
  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  /// Plant eine einmalige Benachrichtigung zu einem exakten Zeitpunkt.
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required int frequencyIndex,
  }) async {
    // Payload enthält alle Daten für eine spätere Neu-Planung
    final payload = jsonEncode({
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime.toIso8601String(),
      'frequency': frequencyIndex,
    });

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      _details(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Plant eine täglich wiederkehrende Benachrichtigung.
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Falls die Uhrzeit heute bereits vorbei ist → morgen planen
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Berechnet die nächste Benachrichtigung
  /// (z. B. wöchentlich oder 4-wöchentlich) anhand des Payloads.
  static Future<void> scheduleNextFromPayload(String payload) async {
    final data = jsonDecode(payload);

    final int frequency = data['frequency'];
    final DateTime lastDate = DateTime.parse(data['dateTime']);

    DateTime? next;

    if (frequency == 1) {
      next = lastDate.add(const Duration(days: 7));
    } else if (frequency == 2) {
      next = lastDate.add(const Duration(days: 28));
    } else {
      return;
    }

    await scheduleOnce(
      id: data['id'],
      title: data['title'],
      body: data['body'],
      dateTime: next,
      frequencyIndex: frequency,
    );
  }

  /// Löscht eine geplante Benachrichtigung anhand der ID.
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }  /// Test-Methode: plant eine Benachrichtigung nach 5 Sekunden.
  /// Wird nur für Entwicklungs- und Testzwecke verwendet.
  static Future<void> testNotificationAfter5Seconds() async {
    await scheduleOnce(
      id: 999,
      title: 'Test Erinnerung',
      body: 'Diese Notification kam nach 5 Sekunden',
      dateTime: DateTime.now().add(const Duration(seconds: 5)),
      frequencyIndex: 0,
    );
  }

}
