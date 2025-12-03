//wird angezeigt wenn auf dem Kalender ein Tag ausgewählt wird

import 'package:flutter/material.dart';

class KalenderAuswahlScreen extends StatelessWidget {
  final DateTime date;  //Variable für den Tag

  //Konstruktor für KalenderAuswahlScreen: date wird als "required" eingestellt
  const KalenderAuswahlScreen({super.key, required this.date});

  final String title = "Kalender Tag ausgewählt";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        //Text enthält ausgwewähltes Datum im DD.MM.YYYY Format
        child: Text("Tag ${date.day}.${date.month}.${date.year} ausgewählt. \nHier werden die ausgefüllten Fragebögen für den Tag angezeigt", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
