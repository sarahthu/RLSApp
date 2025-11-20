import 'package:flutter/material.dart';
import 'package:flutterapp/screens/auswertung_screen.dart';
import 'package:flutterapp/screens/einstellungen_screen.dart';
import 'package:flutterapp/screens/fragebogen_screen.dart';
import 'package:flutterapp/screens/infos_screen.dart';
import 'package:flutterapp/screens/sensor_screen.dart';
import 'package:flutterapp/screens/tagebuch_screen.dart';

//--------------------- Homepage --------------------------------------------------

class HomeScreen extends StatelessWidget {
  final String title = "Home Screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   //Buttons werden mittig in der Column angezeigt
          children: [
            ElevatedButton.icon(    //Knopf zur Fragebogen Seite
              icon: Icon(Icons.question_mark),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {  //Weiterleiten auf FragebogenScreen, mit Zurückknopf
                  return FragebogenScreen();
                }));
              },
              label: const Text('Fragebogen', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(   //Knopf zur Tagebuch Seite
              icon: Icon(Icons.mode_edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf TagebuchScreen, mit Zurückknopf
                  return TagebuchScreen();
                }));
              },
              label: const Text('Tagebuch', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur Sensor Seite
              icon: Icon(Icons.data_exploration_outlined),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {   //Weiterleiten auf SensorScreen, mit Zurückknopf
                  return SensorScreen();
                }));
              },
              label: const Text('Sensordaten', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur Infos Seite
              icon: Icon(Icons.info_outline),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {   //Weiterleiten auf InfosScreen, mit Zurückknopf
                  return InfosScreen();
                }));
              },
              label: const Text('Infos', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur Auswertungs Seite
              icon: Icon(Icons.query_stats),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                  return AuswertungScreen();
                }));
              },
              label: const Text('Auswertungen', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zu den Einstellungen
              icon: Icon(Icons.settings),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf EinstellungenScreen, mit Zurückknopf
                  return EinstellungenScreen();
                }));
              },
              label: const Text('Einstellungen', style: TextStyle(fontSize: 25),),
            ),
          ],
        ),
      ),
    );
  }
}
