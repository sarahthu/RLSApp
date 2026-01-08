//wird angezeigt wenn auf dem Kalender ein Tag ausgewählt wird

import 'package:flutter/material.dart';
import 'package:flutterapp/dio_setup.dart';
import 'package:flutterapp/screens/kalender_fresponse_screen.dart';

class KalenderAuswahlScreen extends StatefulWidget {
  final String date;
  KalenderAuswahlScreen({super.key, required this.date});

  @override
  State<KalenderAuswahlScreen> createState() => _KalenderAuswahlScreenState();
}

class _KalenderAuswahlScreenState extends State<KalenderAuswahlScreen> {
  String title() => "Kalender Tag ${widget.date.substring(0,10)} ausgewählt";
  List items = [];  
  String questionnairetitle = "Titel";
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    get_questionnaireResponses();
  }

  get_questionnaireResponses() async {
    final response = await dio.get("/rls/getresponse/${widget.date.substring(0,10)}");
    if (response.statusCode == 200) {
      setState(() {
        items = response.data;
        isLoading = false;
      });
    } else {
      print('Fehler beim Laden der QuestionnaireResponses');
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
      body: buildfresponselist(items)
    );
  }
}



Widget buildfresponselist(List items){ 
  if (items.isEmpty) { 
    return Center(child: Text("An diesem Tag haben Sie keine Fragebögen ausgefüllt", style: TextStyle(fontSize: 20),)); 
  } 
  else { 
    return ListView.builder( 
      itemCount: items.length, 
      itemBuilder: (context, index) { 
        return GestureDetector( onTap: () { 
          Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf FragebogenScreen, mit Zurückknopf 
          return KalenderfResponseScreen(responsejson: items[index],
          ); 
        })); 
      }, 
      child: Card( 
        child: ListTile( 
          title: Text(items[index]["questionnairetitle"]), 
          subtitle: Text("Score: ${items[index]["score"]} / ${items[index]["maxscore"]}"), 
        ), 
      ), 
      ); 
      }, 
      ); 
    }
  }