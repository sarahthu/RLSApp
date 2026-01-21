import 'package:flutter/material.dart';
import 'package:flutterapp/screens/irls_screen.dart';
import 'package:flutterapp/screens/rlsqol_screen.dart';

<<<<<<< HEAD

class FragebogenScreen extends StatefulWidget {
  final String title = "Fragebogen";
  const FragebogenScreen({super.key});

  @override
  State<FragebogenScreen> createState() => _FragebogenScreenState();
}

class _FragebogenScreenState extends State<FragebogenScreen> {
  Map<String, dynamic>? questionnaire;
  // Speichert Antworten pro Frage
  final Map<String, String> answers = {};
  bool loading = true; //True solange Daten geladen werden
  String? error; //Fehlertext, falls etwas schiefgeht

  @override
  void initState() {
    super.initState();
    loadQuestionnaire(); //Beim Start Fragebogen laden
  }

  //Fragebogen vom Django Server laden
  Future<void> loadQuestionnaire() async {
    try {
      // 10.0.2.2 ist wichtig für Android Emulator
      final url = Uri.parse('http://127.0.0.1:8000/api/rls/questionnaire/');
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        //JSON erfolgreich erhalten → speichern
        setState(() {
          questionnaire = jsonDecode(resp.body);
          loading = false;
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

  //Antworten an Django senden
  Future<void> sendResponse() async {
    if (questionnaire == null) return;

// 🌿 Antworten im Backend-kompatiblen Format aufbauen
    final items = answers.entries.map((entry) {
      return {
        "linkId": entry.key, //ID der Frage
        "answer": [
          {"valueString": entry.value} //Gewählte Antwort
        ]
      };
    }).toList();

    final body = {
      "resourceType": "QuestionnaireResponse", //FHIR-Format
      "questionnaire": questionnaire!["id"],  // ID des Fragebogens
      "status": "completed",
      "item": items,
    };

    final url = Uri.parse('http://127.0.0.1:8000/api/rls/response/');
    // POST Request mit JSON Body
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body), //JSON senden
    );

    debugPrint("Antwort vom Server:");
    debugPrint(resp.body);//Ausgabe in der Debug-Konsole
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
    final items = questionnaire?["item"] as List<dynamic>? ?? [];

=======
class FragebogenScreen extends StatelessWidget {
  final String title = "Fragebogen auswählen:";

  @override
  Widget build(BuildContext context) {
>>>>>>> e9079a118f2d8942e4efe0a0a59707c19f8a4a85
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
<<<<<<< HEAD
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //Jede Frage anzeigen
          for (final item in items)
            _buildQuestionItem(item),
          const SizedBox(height: 20),
          // Button zum Absenden der Antworten
          ElevatedButton(
            onPressed: sendResponse,
            child: const Text("Antwort senden"),
          )
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
              title: Text(opt),
              value: opt,
              groupValue: answers[linkId],
              onChanged: (value) {
                setState(() {
                  answers[linkId] = value!;
                });
=======
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   //Buttons werden mittig in der Column angezeigt
          children: [
            ElevatedButton.icon(    //Knopf zum IRLS Screen
              icon: Icon(Icons.edit_note),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {  //Weiterleiten auf IRLS Screen, mit Zurückknopf
                  return IRLSScreen();
                }));
>>>>>>> e9079a118f2d8942e4efe0a0a59707c19f8a4a85
              },
              label: const Text('Fragebogen 1 (IRLS)', style: TextStyle(fontSize: 25),),
            ),
<<<<<<< HEAD
          const SizedBox(height: 12),
        ],
      );
    }

    //Text antwort
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          onChanged: (val) {
            answers[linkId] = val; //Textantwort speichern
          },
=======
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(   //Knopf zum RLSQoL Screen
              icon: Icon(Icons.edit_note),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf RLSQoL Screen, mit Zurückknopf
                  return RLSQOLScreen();
                }));
              },
              label: const Text('Fragebogen 2 (RLS QoL)', style: TextStyle(fontSize: 25),),
            ),
          ],
>>>>>>> e9079a118f2d8942e4efe0a0a59707c19f8a4a85
        ),
      ),
    );
  }
}
