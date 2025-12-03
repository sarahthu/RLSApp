import 'package:flutter/material.dart';
import 'package:flutterapp/screens/kalender_auswahl_screen.dart';
import 'package:table_calendar/table_calendar.dart';


class KalenderScreen extends StatefulWidget {
  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  final String title = "Kalender";
  DateTime _focusedDay = DateTime.now();  //Variable focusedDay mit initialem Wert DateTime.now()
  DateTime? _selectedDay;  //Variable selectedDay. ? = kann null sein

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   //App bar im Farbschema der App die den Titel des Screens anzeigt
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: TableCalendar(    //Kalender Widget
        firstDay: DateTime.utc(2010, 10, 16),  //Tag ab dem der Kalender anfängt
        lastDay: DateTime.utc(2030, 3, 14),  //Tag ab dem der Kalender aufhört
        focusedDay: _focusedDay,   //bestimmt welcher Monat angezeigt wird (wird auf _focusedDay gesetzt -> wenn man Kalender öffnet sieht man immer den aktuellen Monat)
        onDaySelected: (selectedDay, focusedDay) {   //Wenn Benutzer einen Tag auswählt....
          if (!isSameDay(_selectedDay, selectedDay)) {  //(wird nur dann ausgeführt wenn ein NEUER Tag ausgewählt wird, nicht wenn Benutzer den bereits ausgewählten Tag anklickt)
            setState(() {        //ruft Funktion setState auf
              _selectedDay = selectedDay;  //speichert den vom Benutzer ausgewählten Tag in Variable _selectedDay
              _focusedDay = focusedDay;    //focusedDay ist weiterhin _focusedDay
            });
            
            Navigator.push(    //Navigiert zum KalenderAuswahlScreen, übergibt selectedDay
              context, 
              MaterialPageRoute(
                builder: (context) {
                  return KalenderAuswahlScreen(date: selectedDay);
                }));
            }
        },
      ),
    );
  }
}
