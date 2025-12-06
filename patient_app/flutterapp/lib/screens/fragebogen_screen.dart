import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Screen für die Fragebogenübersicht
class FragebogenScreen extends StatelessWidget {
  final String title = "Fragebogen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Farbe
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Fragebögen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}

//Stateful Widget: RLS Fragebogen

class RlsQuestionnairePage extends StatefulWidget {
  const RlsQuestionnairePage({super.key});

  @override
  State<RlsQuestionnairePage> createState() => _RlsQuestionnairePageState();
}

class _RlsQuestionnairePageState extends State<RlsQuestionnairePage> {
  //geladene Questionnaire als Map
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

    return Scaffold(
      appBar: AppBar(title: const Text("RLS Fragebogen")),
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
              },
            ),
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
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}