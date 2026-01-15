import 'package:flutter/material.dart';
import 'package:flutterapp/screens/tagebuch_auswahl_screen.dart';

class TagebuchScreen extends StatelessWidget {
  final String title = "Tagebuch";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.nights_stay_rounded),
                        ),
                        title: Text("Schlaf"),
                        subtitle: Text("Am besten morgens ausfüllen"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                          return TagebuchAuswahlScreen(id :"tschlaf", title: "Schlaf");
                        }));
                      }
              )
            ),
            Card(
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow,
                          child: Icon(Icons.dining_outlined),
                        ),
                        title: Text("Ernährung"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                          return TagebuchAuswahlScreen(id :"ternaehrung", title: "Ernährung");
                        }));
                      }
              )
            ),
            Card(
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.sports_handball_rounded),
                        ),
                        title: Text("Sport & Bewegung"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                          return TagebuchAuswahlScreen(id :"tsport", title: "Sport & Bewegung");
                        }));
                      }
              )
            ),
            Card(
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.favorite_outline_sharp),
                        ),
                        title: Text("Seelisches Wohlbefinden"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                          return TagebuchAuswahlScreen(id :"twohlbefinden", title: "Seelisches Wohlbefinden");
                        }));
                      }
              )
            ),
          ]
        ),
        ),
    );
  }
}
