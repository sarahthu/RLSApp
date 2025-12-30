import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
=======
import '../services/notification_service.dart'; // Import für lokale Benachrichtigungen
import 'package:flutter/foundation.dart'; // für kIsWeb  (WEB): erkennt Chrome/Web
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)

enum ReminderType { medikament, arzttermin, rezept, fragebogen }
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
<<<<<<< HEAD

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'title': title,
        'timeHour': time.hour,
        'timeMinute': time.minute,
        'dateMillis': date?.millisecondsSinceEpoch,
        'frequency': frequency.index,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      type: ReminderType.values[json['type'] as int],
      title: json['title'] as String,
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      date: (json['dateMillis'] == null)
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['dateMillis'] as int),
      frequency: ReminderFrequency.values[json['frequency'] as int],
    );
  }
=======
  final int notificationId; // Eindeutige ID zum Planen, Löschen und Ändern der Notification
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
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

<<<<<<< HEAD
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey);

    if (list == null) return;

    final loaded = list
        .map((s) => Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    setState(() {
      _reminders
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _reminders.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, list);
  }

=======
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
  bool _dateIsRequired(ReminderType type, ReminderFrequency freq) {
    return type == ReminderType.arzttermin || freq == ReminderFrequency.einmalig;
  }

  String _typeToText(ReminderType type) {
    switch (type) {
      case ReminderType.medikament:
        return 'Medikament';
      case ReminderType.arzttermin:
        return 'Arzttermin';
      case ReminderType.rezept:
        return 'Rezept';
      case ReminderType.fragebogen:
        return 'Fragebogen';
    }
  }

  String _frequencyToText(ReminderFrequency f) {
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

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} Uhr';

  String? _formatDate(DateTime? d) {
    if (d == null) return null;
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
  }

  //  Kombiniert ausgewähltes Datum + Uhrzeit, Wird für das exakte Planen der Notification benötigt
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _showAddReminderDialog() async {
    final formKey = GlobalKey<FormState>();

    ReminderType selectedType = ReminderType.medikament;
    ReminderFrequency selectedFrequency = ReminderFrequency.taeglich;
    final titleController = TextEditingController();

    TimeOfDay? selectedTime;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Neue Erinnerung'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<ReminderType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Art der Erinnerung',
                        ),
                        items: ReminderType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_typeToText(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedType = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titel',
                          hintText: 'z. B. Medikamentenname oder Termin',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bitte einen Titel eingeben';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: () async {
                          final now = TimeOfDay.now();
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? now,
<<<<<<< HEAD
=======
                            builder: (BuildContext context, Widget? child) =>
                                MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: false),
                              child: Localizations.override(
                                context: context,
                                locale: const Locale("de"),
                                child: child!,
                              ),
                            ),
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
                          );
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Uhrzeit'),
                          child: Text(
                            selectedTime == null
                                ? 'Zeit wählen'
                                : _formatTime(selectedTime!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: () async {
                          final today = DateTime.now();
                          final picked = await showDatePicker(
<<<<<<< HEAD
=======
                            locale: const Locale("de"),
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
                            context: context,
                            firstDate: today,
                            lastDate: DateTime(today.year + 5),
                            initialDate: selectedDate ?? today,
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: _dateIsRequired(selectedType, selectedFrequency)
                                ? 'Datum (erforderlich)'
                                : 'Datum (optional)',
                          ),
                          child: Text(
                            selectedDate == null
                                ? 'Datum wählen'
                                : _formatDate(selectedDate!)!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<ReminderFrequency>(
                        value: selectedFrequency,
                        decoration: const InputDecoration(labelText: 'Häufigkeit'),
                        items: ReminderFrequency.values.map((freq) {
                          return DropdownMenuItem(
                            value: freq,
                            child: Text(_frequencyToText(freq)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedFrequency = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Abbrechen'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Erinnerung hinzufügen'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    if (selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bitte eine Uhrzeit wählen')),
                      );
                      return;
                    }

                    if (_dateIsRequired(selectedType, selectedFrequency) &&
                        selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bitte ein Datum wählen')),
                      );
                      return;
                    }

                    // Erzeugt eine eindeutige ID für diese Notification
                    final notificationId =
                        DateTime.now().millisecondsSinceEpoch;

                    final newReminder = Reminder(
                      type: selectedType,
                      title: titleController.text.trim(),
                      time: selectedTime!,
                      date: selectedDate,
                      frequency: selectedFrequency,
                      notificationId: notificationId,
                    );

                    setState(() => _reminders.add(newReminder));
                    await _saveReminders(); 

<<<<<<< HEAD
                    if (mounted) Navigator.of(context).pop();
=======
                    // Berechnet den exakten Zeitpunkt für die Notification
                    final baseDate =
                        selectedDate ?? DateTime.now();
                    final dateTime =
                        _combineDateAndTime(baseDate, selectedTime!);

                    // Notifications im Web/Chrome NICHT ausführen
                    if (!kIsWeb) {
                      // Plant die Notification je nach Häufigkeit
                      switch (selectedFrequency) {
                        case ReminderFrequency.taeglich:
                          NotificationService.scheduleDailyNotification(
                            'Erinnerung',
                            newReminder.title,
                            dateTime,
                            notificationId,
                          );
                          break;

                        case ReminderFrequency.woechentlich:
                          NotificationService.scheduleWeeklyNotification(
                            'Erinnerung',
                            newReminder.title,
                            dateTime,
                            notificationId,
                          );
                          break;

                        case ReminderFrequency.monatlich:
                          NotificationService.scheduleMonthlyNotification(
                            'Erinnerung',
                            newReminder.title,
                            dateTime,
                            notificationId,
                          );
                          break;

                        case ReminderFrequency.einmalig:
                          NotificationService.scheduleOneTimeNotification(
                            'Erinnerung',
                            newReminder.title,
                            dateTime,
                            notificationId,
                          );
                          break;
                      }
                    }

                    Navigator.of(context).pop();
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Erinnerungen'),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Neu'),
              onPressed: _showAddReminderDialog,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _reminders.isEmpty
<<<<<<< HEAD
            ? const Center(child: Text('Noch keine Erinnerungen'))
=======
            ? const Center(
                child: Text(
                  'Noch keine Erinnerungen',
                  style: TextStyle(fontSize: 20),
                ),
              )
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
            : ListView.separated(
                itemCount: _reminders.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = _reminders[index];
                  final dateText = _formatDate(r.date);

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          r.type == ReminderType.medikament
                              ? Icons.medication
                              : Icons.calendar_today,
                        ),
                      ),
                      title: Text(r.title),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(_typeToText(r.type)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(_formatTime(r.time)),
                              if (dateText != null) ...[
                                const SizedBox(width: 12),
                                Text('• $dateText'),
                              ],
                              const SizedBox(width: 12),
                              Text(
                                  '• ${_frequencyToText(r.frequency)}'),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
<<<<<<< HEAD
                          setState(() => _reminders.removeAt(index));
                          await _saveReminders(); 
=======
                          // 🔴 NEU (WEB): Im Web keine Notifications löschen
                          if (!kIsWeb) {
                            await NotificationService
                                .cancelNotification(r.notificationId);
                          }

                          setState(() {
                            _reminders.removeAt(index);
                          });
>>>>>>> 72bf578 (Notification service und Implementierung für Erinnerungen)
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
