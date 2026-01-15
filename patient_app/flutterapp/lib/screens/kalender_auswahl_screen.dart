//wird angezeigt wenn auf dem Kalender ein Tag ausgewählt wird

import 'package:flutter/material.dart';
import 'package:flutterapp/dio_setup.dart';
import 'package:flutterapp/screens/kalender_fresponse_screen.dart';
import 'package:flutterapp/screens/kalender_tresponse_screen.dart';

class KalenderAuswahlScreen extends StatefulWidget {
  final String date;
  KalenderAuswahlScreen({super.key, required this.date});

  @override
  State<KalenderAuswahlScreen> createState() => _KalenderAuswahlScreenState();
}

class _KalenderAuswahlScreenState extends State<KalenderAuswahlScreen> {
  String title() => "Kalender Tag ${widget.date.substring(0,10)} ausgewählt";
  List fragebogen_items = [];  
  List tagebuch_items = [];  

  String questionnairetitle = "Titel";
  bool isLoading = true;
  bool fragebogenGeladen = false;
  bool tagebuchGeladen = false;

  
  @override
  void initState() {
    super.initState();
    get_responses();
  }


  // holt Fragebogen und Tagebuch Antworten vom Backend 
  get_responses() async {
    final fresponse = await dio.get("/rls/getresponse/${widget.date.substring(0,10)}");
    if (fresponse.statusCode == 200) {
      setState(() {
        fragebogen_items = fresponse.data;
        fragebogenGeladen = true;
      });
    } else {
      print('Fehler beim Laden der Fragebogen Responses');
    }

    final tresponse = await dio.get("/rls/gettagebuchresponse/${widget.date.substring(0,10)}");
    if (tresponse.statusCode == 200) {
      setState(() {
        tagebuch_items = tresponse.data;
        tagebuchGeladen = true;
      });
    } else {
      print('Fehler beim Laden der Tagebuch Responses');
    }

    if (fragebogenGeladen && tagebuchGeladen) {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title()),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title()),
      ),
      body: ListView(
        children: [
            SizedBox(height:10),
            Center(child: Text("Fragebögen:", style: TextStyle(fontSize: 30),)),
            buildfresponselist(fragebogen_items),
            SizedBox(height:10),
            Divider(),
            SizedBox(height:10),
            Center(child: Text("Tagebucheinträge:", style: TextStyle(fontSize: 30),)),
            buildtresponselist(tagebuch_items),
          ],
      )
    );
  }
}



Widget buildfresponselist(List fragebogen_items){ 
  if (fragebogen_items.isEmpty) { 
    return Column(
      children: [
        SizedBox(height: 10,),
        Center(child: Text("An diesem Tag haben Sie keine Fragebögen ausgefüllt", style: TextStyle(fontSize: 20),)),
      ],
    ); 
  } 
  else { 
    return ListView.builder( 
      shrinkWrap: true, // stellt sicher dass ListView nur den Platz einnimmt den sie braucht -> macht es möglich Listview zusammen mit anderen Widgets in eine Column zu tun
      itemCount: fragebogen_items.length, 
      itemBuilder: (context, index) { 
        return GestureDetector( onTap: () { 
          Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf FragebogenScreen, mit Zurückknopf 
          return KalenderfResponseScreen(responsejson: fragebogen_items[index],
          ); 
        })); 
      }, 
      child: Card( 
        child: ListTile( 
          title: Text(fragebogen_items[index]["questionnairetitle"]), 
          subtitle: Text("Score: ${fragebogen_items[index]["score"]} / ${fragebogen_items[index]["maxscore"]}"), 
        ), 
      ), 
      ); 
      }, 
      ); 
    }
  }


  Widget buildtresponselist(List tagebuch_items){ 
  if (tagebuch_items.isEmpty) { 
    return Column(
      children: [
        SizedBox(height: 10,),
        Center(child: Text("An diesem Tag haben Sie keine Tagebucheinträge gemacht", style: TextStyle(fontSize: 20),)),
      ],
    ); 
  } 
  else { 
    return ListView.builder( 
      shrinkWrap: true, // stellt sicher dass ListView nur den Platz einnimmt den sie braucht -> macht es möglich Listview zusammen mit anderen Widgets in eine Column zu tun
      itemCount: tagebuch_items.length, 
      itemBuilder: (context, index) { 
        return GestureDetector( onTap: () { 
          Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf FragebogenScreen, mit Zurückknopf 
          return KalendertResponseScreen(responsejson: tagebuch_items[index],); 
        })); 
      }, 
      child: Card( 
        child: ListTile( 
          leading: getCircleAvatar(tagebuch_items[index]["questionnaireid"]),
          title: Text(tagebuch_items[index]["questionnairetitle"]), 
          subtitle: Text("Score: ${tagebuch_items[index]["score"]} / ${tagebuch_items[index]["maxscore"]}"), 
        ), 
      ), 
      ); 
      }, 
      ); 
    }
  }

  CircleAvatar getCircleAvatar(id) {
    if (id == "tschlaf") {
      return CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.nights_stay_rounded),
      );
    }
        if (id == "tsport") {
      return CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.sports_handball_rounded),
      );
    }
        if (id == "ternaehrung") {
      return CircleAvatar(
                          backgroundColor: Colors.yellow,
                          child: Icon(Icons.dining_outlined),
      );
    }
        if (id == "twohlbefinden") {
      return CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.favorite_outline_sharp),
      );
    } else {    //avatar der zurückgegeben wird falls die ID zu keinem von den Tagebuchkategorie-Fragebögen passt.
      return CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(Icons.error),
      );
    }

  }



  Widget tagebuchbuttons(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.blueAccent, // <-- Button color
                  ),
                  child: Icon(Icons.nights_stay_rounded, color: Colors.black, size: 40),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.green, // <-- Button color
                  ),
                  child: Icon(Icons.dining_outlined, color: Colors.black, size: 40),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.orange, // <-- Button color
                  ),
                  child: Icon(Icons.sports_handball_rounded, color: Colors.black, size: 40),
                ),
              ],
            ),
            SizedBox(height:5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.pinkAccent, // <-- Button color
                  ),
                  child: Icon(Icons.favorite_outline_sharp, color: Colors.black, size: 40),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.yellow, // <-- Button color
                  ),
                  child: Icon(Icons.spa_outlined, color: Colors.black, size: 40),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }