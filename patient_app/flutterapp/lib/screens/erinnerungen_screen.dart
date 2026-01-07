import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import '../services/notification_service.dart';

enum ReminderType { medikament, arzttermin, rezept, fragebogen }
// WIE und WANN Benachrichtigungen geplant werden
enum ReminderFrequency { taeglich, woechentlich, alle4wochen, einmalig }

class Reminder {
  Reminder({
    required this.type,
    required this.title,
    required this.time,
    this.date,
    required this.frequency,
    required this.notificationId,
  });

  final ReminderType type;
  final String title;
  final TimeOfDay time;
  final DateTime? date;
  final ReminderFrequency frequency;
  final int notificationId;

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'title': title,
        'timeHour': time.hour,
        'timeMinute': time.minute,
        'dateMillis': date?.millisecondsSinceEpoch,
        'frequency': frequency.index,
        'notificationId': notificationId,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      type: ReminderType.values[json['type']],
      title: json['title'],
      time: TimeOfDay(
        hour: json['timeHour'],
        minute: json['timeMinute'],
      ),
      date: json['dateMillis'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['dateMillis']),
      frequency: ReminderFrequency.values[json['frequency']],
      notificationId: json['notificationId'],
    );
  }
}

class ErinnerungenScreen extends StatefulWidget {
  const ErinnerungenScreen({super.key});

  @override
  State<ErinnerungenScreen> createState() => _ErinnerungenScreenState();
}

class _ErinnerungenScreenState extends State<ErinnerungenScreen>
    with AutomaticKeepAliveClientMixin {
  static const _storageKey = 'rls_reminders_v1';

  @override
  bool get wantKeepAlive => true;

  final List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey);
    if (list == null) return;

    setState(() {
      _reminders
        ..clear()
        ..addAll(list.map((e) => Reminder.fromJson(jsonDecode(e))));
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _reminders.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} Uhr';

  String _frequencyText(ReminderFrequency f) {
    switch (f) {
      case ReminderFrequency.taeglich:
        return 'Täglich';
      case ReminderFrequency.woechentlich:
        return 'Wöchentlich';
      case ReminderFrequency.alle4wochen:
        return 'Alle 4 Wochen';
      case ReminderFrequency.einmalig:
        return 'Einmalig';
    }
  }

  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  Future<void> _addReminderDialog() async {
    final formKey = GlobalKey<FormState>();

    ReminderFrequency frequency = ReminderFrequency.taeglich;
    TimeOfDay? time;
    DateTime? date;
    final titleCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Neue Erinnerung'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titel'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Titel fehlt' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setStateDialog(() => time = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Uhrzeit'),
                    child: Text(
                        time == null ? 'Zeit wählen' : _formatTime(time!)),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                      initialDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setStateDialog(() => date = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Datum (optional)'),
                    child: Text(
                        date == null
                            ? 'Heute'
                            : date!.toLocal().toString().split(' ')[0]),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReminderFrequency>(
                  value: frequency,
                  items: ReminderFrequency.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(_frequencyText(f)),
                          ))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => frequency = v!),
                  decoration:
                      const InputDecoration(labelText: 'Häufigkeit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              child: const Text('Speichern'),
              onPressed: () async {
                if (!formKey.currentState!.validate() || time == null) return;

                final id =
                    DateTime.now().millisecondsSinceEpoch % 1000000000;

                final baseDate = date ?? DateTime.now();
                final dateTime = _combine(baseDate, time!);

                if (frequency == ReminderFrequency.einmalig &&
                    dateTime.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Zeitpunkt liegt in der Vergangenheit')),
                  );
                  return;
                }

                final reminder = Reminder(
                  type: ReminderType.medikament,
                  title: titleCtrl.text.trim(),
                  time: time!,
                  date: date,
                  frequency: frequency,
                  notificationId: id,
                );

                setState(() => _reminders.add(reminder));
                await _saveReminders();

                if (!kIsWeb) {
                  switch (frequency) {
                    case ReminderFrequency.taeglich:
                      await NotificationService.scheduleDaily(
                        id: id,
                        title: 'Erinnerung',
                        body: reminder.title,
                        time: dateTime,
                      );
                      break;

                    case ReminderFrequency.woechentlich:
                      await NotificationService.scheduleOnce(
                        id: id,
                        title: 'Erinnerung',
                        body: reminder.title,
                        dateTime: dateTime,
                        frequencyIndex: frequency.index,
                      );
                      break;

                    case ReminderFrequency.alle4wochen:
                      await NotificationService.scheduleOnce(
                        id: id,
                        title: 'Erinnerung',
                        body: reminder.title,
                        dateTime:
                            dateTime.add(const Duration(days: 28)),
                        frequencyIndex: frequency.index,
                      );
                      break;

                    case ReminderFrequency.einmalig:
                      await NotificationService.scheduleOnce(
                        id: id,
                        title: 'Erinnerung',
                        body: reminder.title,
                        dateTime: dateTime,
                        frequencyIndex: frequency.index,
                      );
                      break;
                  }
                }

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erinnerungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addReminderDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (_, i) {
          final r = _reminders[i];
          return ListTile(
            title: Text(r.title),
            subtitle:
                Text('${_formatTime(r.time)} • ${_frequencyText(r.frequency)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (!kIsWeb) {
                  await NotificationService.cancel(r.notificationId);
                }
                setState(() => _reminders.removeAt(i));
                await _saveReminders();
              },
            ),
          );
        },
      ),
    );
  }
}
