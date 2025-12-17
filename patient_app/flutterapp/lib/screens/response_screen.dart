import 'package:flutter/material.dart';

class ResponseScreen extends StatefulWidget {
  final Map<String, dynamic>? responsejson;
  const ResponseScreen({super.key, required this.responsejson});

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  final String title = "QuestionnaireResponse Details";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text("Fragebogen: ${widget.responsejson?["questionnairetitle"]}", style: TextStyle(fontSize: 20),),
            Text("ausgefüllt am ${widget.responsejson?["date"].substring(0,10)}, um ${widget.responsejson?["date"].substring(11,16)} Uhr", style: TextStyle(fontSize: 15),),
            SizedBox(height: 10,),
            Card(
              color: Theme.of(context).colorScheme.inversePrimary,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Erzielter Score: ${widget.responsejson?["score"]} / ${widget.responsejson?["maxscore"]}", style: TextStyle(fontSize: 20),),
              ),
            ),
            Divider(),
            Text("Antworten:", style: TextStyle(fontSize: 20),),
            Expanded(
              child: ListView.builder(
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
            )
          ],
        ),
      ),
    );
  }
}
