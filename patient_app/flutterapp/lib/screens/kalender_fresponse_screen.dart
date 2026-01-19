import 'package:flutter/material.dart';

class KalenderfResponseScreen extends StatefulWidget { //zeigt eine bestimmte Fragebogen-Antwort an, die bei einem Kalendertag-Screen ausgeählt wurde
  final Map<String, dynamic>? responsejson;  //erhält dafür eine JSON die alle Daten zu der Fragebogen-Antwort enthält
  const KalenderfResponseScreen({super.key, required this.responsejson});

  @override
  State<KalenderfResponseScreen> createState() => _KalenderfResponseScreenState();
}

class _KalenderfResponseScreenState extends State<KalenderfResponseScreen> {
  final String title = "Fragebogenantwort Details";

  // -------------------------------- Build Methode ------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
          children: [
                // ----------------------------- Abschnitt für allgemeine Infos über den Fragebogen ----------------------------------------------
                Column(
                  children: [
                    SizedBox(height: 10,),
                    Text("${widget.responsejson?["questionnairetitle"]}", style: TextStyle(fontSize: 20),),  //Titel des Fragebogens
                    Text("ausgefüllt am ${widget.responsejson?["date"].substring(0,10)}, um ${widget.responsejson?["date"].substring(11,16)} Uhr", style: TextStyle(fontSize: 15),), // Datum und Uhrzeit
                    SizedBox(height: 10,),
                    Card(   // grüne Karte die den Score darstellt
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Score: ${widget.responsejson?["score"]} / ${widget.responsejson?["maxscore"]}", style: TextStyle(fontSize: 20),),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Card(   // grüne Karte die die Score Interpretation darstellt
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("---> ${widget.responsejson?["interpretation"]}", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                      ),
                    ),
                  ],
                ),
                Divider(), // Trenstrich
                SizedBox(height:10),
                // ------------------------- Abschnitt für Fragen + Antworten ---------------------------------------------------------
                Center(child: Text("Antworten:", style: TextStyle(fontSize: 20),)),
                ListView.builder(  // generiert eine Liste mit allen Fragebogen-Fragen und den Antworten
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), //macht die kleine 2te Listview nicht-scrollable
                      itemCount: widget.responsejson?["questions"].length,
                      itemBuilder: (context, index) {
                        return ListTile(
                              title: Text(
                                "Frage ${index+1}: ${widget.responsejson?["questions"][index]["question"]}",
                                style: TextStyle(fontSize: 15,),),
                              subtitle: Text(
                                "---> ${widget.responsejson?["questions"][index]["answer"].substring(1)}", 
                                style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),),
                        );
                      }
                  )
            ],
      ),
    );
  }
}
