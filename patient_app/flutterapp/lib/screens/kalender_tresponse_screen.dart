import 'package:flutter/material.dart';

class KalendertResponseScreen extends StatefulWidget {
  final Map<String, dynamic>? responsejson;
  const KalendertResponseScreen({super.key, required this.responsejson});

  @override
  State<KalendertResponseScreen> createState() => _KalendertResponseScreenState();
}

class _KalendertResponseScreenState extends State<KalendertResponseScreen> {
  final String title = "QuestionnaireResponse Details";
  // Datum von der Questionnaireresponse Ressource in die richtige Zeitzone
  //DateTime get parsedDate => DateTime.parse(widget.responsejson?["date"]);   //converts "date" from the jsonresponse into a DateTime variable
  //String get localdateString => parsedDate.toLocal().toString();  //changes Date to local timezone and converts it back into String

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
          children: [
            Column(
              children: [
                SizedBox(height: 10,),
                Text("Kategorie: ${widget.responsejson?["questionnairetitle"]}", style: TextStyle(fontSize: 20),),
                Text("ausgefüllt am ${widget.responsejson?["date"].substring(0,10)}, um ${widget.responsejson?["date"].substring(11,16)} Uhr", style: TextStyle(fontSize: 15),),
                SizedBox(height: 10,),
                Card(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Erzielter Score: ${widget.responsejson?["score"]} / ${widget.responsejson?["maxscore"]}", style: TextStyle(fontSize: 20),),
                  ),
                ),
                SizedBox(height: 5,),
                Card(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("---> ${widget.responsejson?["interpretation"]}", style: TextStyle(fontSize: 20),),
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height:10),
            Center(child: Text("Antworten:", style: TextStyle(fontSize: 20),)),
            ListView.builder(
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
            ),
            SizedBox(height:10),
            Divider(),
            SizedBox(height:10),
            Center(child: Text("Tagebucheinträge:", style: TextStyle(fontSize: 20),)),
            SizedBox(height: 10,),
            ListTile(
              title: Text("öffentlich:", style: TextStyle(fontSize: 15,),),
              subtitle: formatiereEntry(widget.responsejson?["publicentry"]),
            ),
            SizedBox(height:5),
            ListTile(
              title: Text("privat:", style: TextStyle(fontSize: 15),),
              subtitle: formatiereEntry(widget.responsejson?["privateentry"]),
            ),
          ],
        ),
    );
  }
}

Widget formatiereEntry(text) {
  if (text == "null") {
    return Text("Kein Tagebucheintrag vorhanden");
  }
  else {
    return Text(text);
  }
}