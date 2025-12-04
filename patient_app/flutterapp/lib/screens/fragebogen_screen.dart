import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FragebogenScreen extends StatelessWidget {
  final String title = "Fragebogen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Fragebögen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}


class RlsQuestionnairePage extends StatefulWidget {
  const RlsQuestionnairePage({super.key});

  @override
  State<RlsQuestionnairePage> createState() => _RlsQuestionnairePageState();
}

class _RlsQuestionnairePageState extends State<RlsQuestionnairePage> {
  Map<String, dynamic>? questionnaire;
  final Map<String, String> answers = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadQuestionnaire();
  }

  //Fragebogen vom Django Server laden
  Future<void> loadQuestionnaire() async {
    try {
      // 10.0.2.2 ist wichtig für Android Emulator
      final url = Uri.parse('http://127.0.0.1:8000/api/rls/questionnaire/');
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
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

    final items = answers.entries.map((entry) {
      return {
        "linkId": entry.key,
        "answer": [
          {"valueString": entry.value}
        ]
      };
    }).toList();

    final body = {
      "resourceType": "QuestionnaireResponse",
      "questionnaire": questionnaire!["id"],
      "status": "completed",
      "item": items,
    };

    final url = Uri.parse('http://127.0.0.1:8000/api/rls/response/');
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    debugPrint("Antwort vom Server:");
    debugPrint(resp.body);
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

    final items = questionnaire?["item"] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("RLS Fragebogen")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in items)
            _buildQuestionItem(item),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: sendResponse,
            child: const Text("Antwort senden"),
          )
        ],
      ),
    );
  }

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
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
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

    // text answer
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          onChanged: (val) {
            answers[linkId] = val;
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}