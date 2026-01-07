import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterapp/dio_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';


class IRLSScreen extends StatefulWidget {
  const IRLSScreen({super.key});

  @override
  State<IRLSScreen> createState() => _IRLSScreenState();
}

class _IRLSScreenState extends State<IRLSScreen> {
  final String id = "f1"; //ID des Fragebogens auf dem FHIR Server
  final String title = "International RLS Scale"; //Titel des Screens


  Map<String, dynamic>? questionnaire; // Speichert Antworten pro Frage
  final Map<String, String> answers = {};
  bool loading = true; //True solange Daten geladen werden
  String? error; //Fehlertext, falls etwas schiefgeht
  Map<String, dynamic>? djangoresponse; //Speichert die Antwort die vom Backend nach Speichern des Fragebogens zurückkommt
  int score = 0; //Integer für den Fragebogen Score (wird bei speichern von QuestionnaireResponse von Django übergeben)
  int maxscore = 0; //Integer für dem maximalen Score der auf dem Fragebogen erzielt werden kann


  @override
  void initState() {
    super.initState();
    loadQuestionnaire();  //Beim Start Fragebogen laden
    loadAnswersOffline();
  }
Future<void> saveAnswersOffline() async {
  final prefs = await SharedPreferences.getInstance();

  final jsonString = jsonEncode(answers);     //Die Antworten werden als JSON-String gespeichert, damit sie nach einem App-Neustart oder ohne Internetverbindung wiederhergestellt werden können.

  // Key z.B. pro Fragebogen-ID
  await prefs.setString('irls_answers_$id', jsonString);
}

Future<void> loadAnswersOffline() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('irls_answers_$id');

  if (jsonString == null) return;

  final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  setState(() {
    answers
      ..clear()
      ..addAll(decoded.map((k, v) => MapEntry(k, v.toString())));
  });
}

  //---------------Fragebogen vom Django Server laden--------------------------------------------------
  Future<void> loadQuestionnaire() async {
    final cacheBox = Hive.box('questionnaire_cache');
  final cacheKey = 'questionnaire_$id';

    try {
      // 10.0.2.2 ist wichtig für Android Emulator
      // 127.0.0.1:8000 für Edge und co
      final resp = await dio.get("/rls/questionnaire/$id");

      if (resp.statusCode == 200) {
        //JSON erfolgreich erhalten → speichern
        setState(() {
          questionnaire = resp.data;
          loading = false;
          maxscore = questionnaire?["item"][0]["extension"][0]["valueInteger"]; //Speichet maximal erreichbaren Score in Variable Maxscore
        });
      } else {
        setState(() {
          error = 'Fehler: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Fehler: $e';
        loading = false;
      });
    }
  }

  //------------------------------Antworten an Django senden-----------------------------------------------
  Future<void> sendResponse() async {
    final date = DateTime.now(); //Variable die Zeit speichert zu der der Fragebogen abgesendet wurde
    if (questionnaire == null) return;

    //Antworten im Backend-kompatiblen Format aufbauen
    final items = answers.entries.map((entry) {
      return {
        "linkId": entry.key, //ID der Frage
        "answer": [
          {"valueString": entry.value} //Gewählte Antwort
        ]
      };
    }).toList();

    //erstellt eine JSON im FHIR QuestionnaireResponse Format, mit den eingegebenen Antworten und Score=null (wir später im Backend berechnet)
    final body = {
      "resourceType": "QuestionnaireResponse", //FHIR-Format
      "id" : "r${questionnaire!["id"]}${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}",
      "questionnaire": "https://i-lv-prj-01.informatik.hs-ulm.de/Questionnaire/$id",  // Link zum Fragebogen auf dem Server
      "status": "completed",
      "authored" : date.toUtc().toIso8601String(),
      "item": [
        {
          "linkId": "0",
          "valueInteger": null
        },
        {
          "linkId": "1",
          "item": items
        }
      ]
    };

    try {
      final resp = await dio.post("/rls/response/",   //verwendet dio das in dio_setup erstellt wurde
        data: body,
      );

      if (resp.statusCode == 200) {
          //wenn Fragebogen erfolgreich gesendet und eine Antwort vom Backend erhalten wurde
          djangoresponse = resp.data;
          score = djangoresponse?["score"];

      }

      debugPrint("Antwort vom Server:");
      debugPrint(resp.data);//Ausgabe in der Debug-Konsole
    } catch (e) {
      print('Fehler beim Speicher der Fragebogen-Antwort: $e');
    }

  }



  //-------------------Pop-Up Fenster das den Score anzeigt----------------------------------------------
  Future<void> showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Benutzer muss den Knopf drücken um weiter zu kommen
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Antworten gespeichert!'),  //Titel des Pop-up Fensters
        content: SingleChildScrollView(
          child: Text('Ihr RLS-Score ist $score/$maxscore!', style: TextStyle(fontSize: 20),), //Text des Pop-up Fensters
        ),
        actionsAlignment: MainAxisAlignment.center, //"Okay" Button steht mittig vom Pop-up
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();  //schließt Pop-up (navigiert zurück zum RLSQOLScreen)
              Navigator.of(context).pop();  //navigiert zurück zum FragebogenScreen

            },
          ),
        ],
      );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    // Fragen aus dem Fragebogen holen
    final items = (questionnaire?['item'] as List?)?[1]?['item'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //Jede Frage anzeigen
          for (final item in items)
            _buildQuestionItem(item),
          const SizedBox(height: 20),
          // Button zum Absenden der Antworten
          ElevatedButton(
            onPressed: () async {
                await sendResponse();  //Button wartet bis sendResponse (Funktion die Antworten zum Django Backend sendet) abgeschlossen ist
                showMyDialog(); //wenn sendResponse fertig ist (=wenn Score unter int score gespeichert ist), wird Pop Up angezeigt 
            },
            child: const Text("Antworten senden"),
          ),
        ],
      ),
    );
  }

  //Baut passende Eingabefeld
  Widget _buildQuestionItem(Map<String, dynamic> item) {
    final linkId = item["linkId"];
    final text = item["text"];
    final type = item["type"];

    if (type == "choice") {
      final options = (item["answerOption"] as List)
          .map((opt) => opt["valueString"] as String)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)), //Frage anzeigen
          //Für jede Option einen Button erstellen
          for (final opt in options)
            RadioListTile<String>(
              title: Text(opt.substring(1)),  //Zeigt die erste Stelle der AntwortOptionen (=den Score-Wert) nicht mit an
              value: opt,
              groupValue: answers[linkId],
              onChanged: (value) async {
                setState(() {
                  answers[linkId] = value!;
                });
                await saveAnswersOffline();
              },
            ),
          const SizedBox(height: 12),
        ],
      );
    }

    // text answer
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          onChanged: (val) async {
            answers[linkId] = val;   //Textantwort speichern
            await saveAnswersOffline();
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
