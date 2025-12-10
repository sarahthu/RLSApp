import 'package:flutter/material.dart';
import 'package:flutterapp/screens/irlss_screen.dart';
import 'package:flutterapp/screens/rlsqol_screen.dart';

class FragebogenScreen extends StatelessWidget {
  final String title = "Fragebogen auswählen:";

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
              icon: Icon(Icons.edit_note),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {  //Weiterleiten auf FragebogenScreen, mit Zurückknopf
                  return IRLSSScreen();
                }));
              },
              label: const Text('IRLSS', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(   //Knopf zur Tagebuch Seite
              icon: Icon(Icons.edit_note),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf TagebuchScreen, mit Zurückknopf
                  return RLSQOLScreen();
                }));
              },
              label: const Text('RLS QoL', style: TextStyle(fontSize: 25),),
            ),
          ],
        ),
      ),
    );
  }
}
